module SpreeCmCommissioner
  class CustomerNotificationSender < BaseInteractor
    delegate :user_ids, :customer_notification, to: :context

    def call
      send_notification
      update_sent_at
    end

    # even sent_at is present, it still can be sent
    # but will only to users that not yet received the notification
    def update_sent_at
      customer_notification.sent_at = Time.current
      customer_notification.save
    end

    def send_notification
      if user_ids.present?
        send_to_specific_users(user_ids)
      else
        send_to_target_users
      end
    end

    def send_to_specific_users(user_ids)
      users = Spree::User.push_notificable.where(id: user_ids)
      users.find_each do |user|
        deliver_notification_to_user(user)
      end
    end

    def send_to_target_users
      users_not_received_notifications.find_each do |user|
        deliver_notification_to_user(user)
      end
    end

    def deliver_notification_to_user(user)
      SpreeCmCommissioner::CustomerContentNotificationCreator.call(
        user_id: user.id,
        customer_notification_id: customer_notification.id
      )
    end

    def users_not_received_notifications
      end_users
        .joins(
          "LEFT JOIN cm_notifications ON (
            cm_notifications.recipient_id = spree_users.id
            AND cm_notifications.notificable_type = 'SpreeCmCommissioner::CustomerNotification'
            AND cm_notifications.notificable_id = #{customer_notification.id}
          )"
        )
        .where(cm_notifications: { id: nil })
    end

    def end_users
      if customer_notification.notification_taxons.exists?
        taxon_ids = []
        customer_notification.notification_taxons.select(:taxon_id).find_each(batch_size: 1000) do |taxon|
          taxon_ids << taxon.taxon_id
        end
        SpreeCmCommissioner::UsersByEventFetcherQuery
          .new(taxon_ids)
          .call
          .end_users_push_notificable
      else
        Spree.user_class.end_users_push_notificable
      end
    end
  end
end
