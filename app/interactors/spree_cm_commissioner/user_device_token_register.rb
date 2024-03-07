module SpreeCmCommissioner
  class UserDeviceTokenRegister < BaseInteractor
    delegate :user, to: :context

    def call
      find_or_create_device_token
    end

    private

    def find_or_create_device_token
      context.device_token = user.device_tokens.find_or_initialize_by(
        registration_token: context.registration_token,
        client_name: context.client_name
      )

      update_device_token_attributes
      save_device_token
    end

    def update_device_token_attributes
      return if context.device_token.persisted?

      context.device_token.assign_attributes(
        client_version: context.client_version,
        device_type: context.device_type
      )
    end

    def save_device_token
      return if context.device_token.persisted?

      context.device_token.save ||
        context.fail!(message: context.device_token.errors.full_messages.to_sentence)
    end
  end
end
