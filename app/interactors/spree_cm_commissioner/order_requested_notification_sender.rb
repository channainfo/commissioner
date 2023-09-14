module SpreeCmCommissioner
  class OrderRequestedNotificationSender < BaseInteractor
    def call
      notification = SpreeCmCommissioner::OrderRequestedNotification.with(
        order: context.order
      ).deliver_later(context.order.user)

      context.notification = notification
    end
  end
end
