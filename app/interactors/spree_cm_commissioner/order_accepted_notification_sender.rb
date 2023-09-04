module SpreeCmCommissioner
  class OrderAcceptedNotificationSender < BaseInteractor
    def call
      notification = SpreeCmCommissioner::OrderAcceptedNotification.with(
        order: context.order
      ).deliver_later(context.order.user)

      context.notification = notification
    end
  end
end
