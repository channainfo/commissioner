module SpreeCmCommissioner
  class VattanacBankInitiator
    include Interactor

    def call
      extract_encrypted_data_and_signature
      verify_signature
      decrypt_payload
      find_or_create_user
      construct_data
    end

    private

    def extract_encrypted_data_and_signature
      data_param = context.params[:data]
      context.fail!(message: 'Invalid payload format', status: :bad_request) if data_param.blank?

      parts = data_param.to_s.split('.', 2)
      context.fail!(message: 'Invalid payload format', status: :bad_request) unless parts.size == 2

      encrypted_data, signature = parts
      context.encrypted_data = encrypted_data
      context.signature = signature
    end

    def verify_signature
      rsa_service = SpreeCmCommissioner::RsaService.new(
        public_key: vattanac_public_key
      )

      return if rsa_service.verify(context.encrypted_data, context.signature)

      context.fail!(message: 'Invalid signature', status: :unauthorized)
    end

    def decrypt_payload
      context.fail!(message: 'Invalid AES key length', status: :unprocessable_entity) unless aes_key

      begin
        decrypted_json = SpreeCmCommissioner::AesEncryptionService.decrypt(context.encrypted_data, aes_key)
        context.user_data = JSON.parse(decrypted_json)
      rescue StandardError => e
        context.fail!(message: 'Decryption failed', error: e.message, status: :unprocessable_entity)
      end
    end

    def find_or_create_user
      find_user_by_identity || find_existing_user || create_new_user
    end

    def find_user_by_identity
      user_data = context.user_data

      identity = SpreeCmCommissioner::UserIdentityProvider.vattanac_bank
                                                          .find_or_initialize_by(sub: user_data['phoneNum'])

      if identity.persisted?
        context.user = identity.user
      else
        context.identity = identity
      end

      context.user
    end

    def find_existing_user
      user_data = context.user_data

      context.user = Spree::User.find_by(
        'email = ? OR phone_number = ?', user_data['email'], user_data['phoneNum']
      )
    end

    def create_new_user
      user_data = context.user_data
      full_name = "#{user_data['firstName']} #{user_data['lastName']}"
      identity = context.identity

      identity.name = full_name
      identity.email = user_data['email']
      context.user = Spree::User.new(
        first_name: user_data['firstName'],
        last_name: user_data['lastName'],
        email: user_data['email'],
        phone_number: user_data['phoneNum'],
        password: SecureRandom.base64(16),
        user_identity_providers: [identity]
      )

      return if context.user.save

      context.fail!(message: "User creation failed: #{context.user.errors.full_messages.join(', ')}")
    end

    def construct_data
      user = context.user

      raw_data = {
        sessionId: session_id,
        name: user.full_name,
        phone: user.phone_number,
        email: user.email,
        webUrl: "#{Spree::Store.default.formatted_url}/vattanac_bank_web_app?session_id=#{session_id}"
      }

      json_data = raw_data.to_json

      encrypted_data = SpreeCmCommissioner::AesEncryptionService.encrypt(json_data, aes_key)

      rsa_service = SpreeCmCommissioner::RsaService.new(private_key: bookmeplus_private_key)

      signed_data = rsa_service.sign(encrypted_data)

      context.data = signed_data
    end

    def session_id
      payload = { user_id: context.user.id }
      SpreeCmCommissioner::UserSessionJwtToken.encode(payload, context.user.reload.secure_token)
    end

    def aes_key
      ENV['VATTANAC_AES_SECRET_KEY'].presence || Rails.application.credentials.vattanac.aes_secret_key
    end

    def bookmeplus_private_key
      ENV['BOOKMEPLUS_PRIVATE_KEY'].presence || Rails.application.credentials.bookmeplus.private_key
    end

    def vattanac_public_key
      ENV['VATTANAC_PUBLIC_KEY'].presence || Rails.application.credentials.vattanac.public_key
    end
  end
end
