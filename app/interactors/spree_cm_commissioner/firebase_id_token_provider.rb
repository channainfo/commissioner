module SpreeCmCommissioner
  class FirebaseIdTokenProvider < BaseInteractor
    # :id_token
    def call
      claim = decode_id_token

      if claim
        context.claim = claim
        context.provider = extract_provider_params
      else
        error_message = I18n.t('firebase_id_token.failure')
        context.fail!(message: error_message)
      end
    end

    # Response sample:
    # ---------- Header --------
    # {
    #   "alg": "RS256",
    #   "kid": "cf5d8e74f3c486ee503d5eec93a101c64bacf7da",
    #   "typ": "JWT"
    # }
    # ---------- Body --------
    # {
    #   "iss": "https://securetoken.google.com/vtenh-46ed3",
    #   "aud": "vtenh-46ed3",
    #   "auth_time": 1646117677,
    #   "user_id": "C3O4jmfZsAYQn9vJxDZZFNhmETj2",
    #   "sub": "C3O4jmfZsAYQn9vJxDZZFNhmETj2",
    #   "iat": 1646117677,
    #   "exp": 1646121277,
    #   "firebase": {
    #     "sign_in_provider": "apple.com"
    #     "identities": {
    #       "apple.com": [
    #         "000561.52d801e34d58420a9bbc75d3f13f8a91.1143"
    #       ]
    #     },
    #   }
    # }

    # https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library
    # https://github.com/jwt/ruby-jwt/issues/216

    def decode_id_token
      result = JWT.decode(id_token, nil, false, { algorithm: 'RS256' }) do |header|
        kid = header['kid']
        cert = cert_generation(kid)
        public_key = OpenSSL::X509::Certificate.new(cert).public_key
        public_key
      end
      result[0]
    rescue StandardError => e
      context.fail!(message: e.message)
    end

    def cert_generation(kid)
      json = fetch_cert_key
      cert = json[kid]

      if cert.nil?
        json = refresh_fetch_cert_key
        cert = json[kid]
      end

      cert
    end

    def refresh_fetch_cert_key
      Rails.cache.delete('firebase-cert')
      fetch_cert_key
    end

    def fetch_cert_key
      Rails.cache.fetch('firebase-cert') do
        url = URI('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com')
        content = Net::HTTP.get(url)
        JSON.parse(content)
      end
    end

    def extract_provider_params
      claim = context.claim

      return nil if claim.nil?

      provider_name = claim['firebase']['sign_in_provider']
      user_id = claim['user_id']
      sub = claim['firebase']['identities'][provider_name].first
      email = claim['email'] || get_user_email(user_id)
      name = claim['name']

      {
        identity_type: provider_name.split('.').first,
        sub: sub,
        name: name,
        email: email
      }
    end

    def get_user_email(user_id)
      return nil if user_id.blank?

      firebase_context = FirebaseEmailFetcher.call(user_id: user_id)

      return unless firebase_context.success?

      firebase_context.email
    end

    delegate :id_token, to: :context
  end
end
