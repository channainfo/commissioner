module SpreeCmCommissioner
  class OrderCompleteNotificationSender < BaseInteractor
    def call
      notification = SpreeCmCommissioner::OrderCompleteNotification.with(
        order: context.order
      ).deliver_later(context.order.user)

      context.notification = notification
    end
  end
end
