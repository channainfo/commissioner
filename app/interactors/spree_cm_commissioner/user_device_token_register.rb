module SpreeCmCommissioner
  class UserDeviceTokenRegister < BaseInteractor
    delegate :user, to: :context

    def call
      delete_existing_device_token
      register_device_token
    end

    private

    def delete_existing_device_token
      device_token = DeviceToken.find_by(registration_token: context.registration_token)
      device_token&.destroy
    end

    def register_device_token
      context.device_token = user.device_tokens.find_or_initialize_by(
        registration_token: context.registration_token,
        client_name: context.client_name
      )

      context.device_token.assign_attributes(
        client_version: context.client_version,
        device_type: context.device_type
      )

      return if context.device_token.save

      context.fail!(message: context.device_token.errors.full_messages.to_sentence)
    end
  end
end
