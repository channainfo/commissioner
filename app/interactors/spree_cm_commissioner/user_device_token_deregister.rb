module SpreeCmCommissioner
  class UserDeviceTokenDeregister < BaseInteractor
    delegate :user, to: :context

    def call
      remove_device_token
    end

    def remove_device_token
      context.device_token = context.user.device_tokens.find_by(registration_token: context.registration_token)
      context.fail!(message: 'Device token not found') if context.device_token.nil?
      context.fail!(message: 'Fail to remove device token') unless context.device_token.destroy
    end
  end
end
