module SpreeCmCommissioner
  class OrderRejectedNotificationSender < BaseInteractor
    def call
      notification = SpreeCmCommissioner::OrderRejectedNotification.with(
        order: context.order
      ).deliver_later(context.order.user)

      context.notification = notification
    end
  end
end
