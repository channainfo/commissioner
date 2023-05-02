module SpreeCmCommissioner
  class UserDeviceTokenRegister < BaseInteractor
    delegate :user, to: :context

    def call
      create_device_token
    end

    def device_token_exist?
      context.device_token ||= user.device_tokens.where(
        registration_token: context.registration_token,
        client_name: context.client_name
      ).first_or_initialize do |device_token|
        device_token.client_version = context.client_version
      end

      context.device_token.persisted?
    end

    def create_device_token
      return if device_token_exist?

      context.fail!(message: context.device_token.errors.full_messages.to_sentence) unless context.device_token.save
    end
  end
end
