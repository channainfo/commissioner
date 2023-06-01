module SpreeCmCommissioner
  class CustomerContentNotificationCreator < BaseInteractor
    def call
      validate_user
      validate_customer_notification

      SpreeCmCommissioner::CustomerContentNotification.with(
        customer_notification: context.customer_notification
      ).deliver(context.user)
    end

    private

    def validate_user
      context.user = Spree::User.find_by(id: context.user_id)
      context.fail!(message: 'User not found') if context.user.nil?
    end

    def validate_customer_notification
      context.customer_notification =  SpreeCmCommissioner::CustomerNotification.find_by(id: context.customer_notification_id)
      context.fail!(message: 'Customer notification not found') if context.customer_notification.nil?
    end
  end
end
