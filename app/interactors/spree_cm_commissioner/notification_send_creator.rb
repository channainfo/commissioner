module SpreeCmCommissioner
  class NotificationSendCreator < BaseInteractor
    delegate :send_all, :customer_notification, :user_ids, to: :context

    def call
      if send_all
        handle_send_all
      else
        handle_send_specific
      end
    end

    private

    def handle_send_all
      if customer_notification.notification_taxons.present?
        user_ids = users(customer_notification.notification_taxons.pluck(:taxon_id)).pluck(:id)
        context.notice_key = 'notification.send_specific_in_progress'
      else
        user_ids = nil
        context.notice_key = 'notification.send_all_in_progress'
      end
      SpreeCmCommissioner::CustomerNotificationSenderJob.perform_later(customer_notification.id, user_ids)
    end

    def handle_send_specific
      SpreeCmCommissioner::CustomerNotificationSenderJob.perform_later(customer_notification.id, user_ids)
      context.notice_key = 'notification.send_specific_in_progress'
    end

    def users(taxon_id)
      SpreeCmCommissioner::UsersByEventFetcherQuery.new(taxon_id).call
    end
  end
end
