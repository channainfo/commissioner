module SpreeCmCommissioner
  class OrderAcceptedNotification < NoticedFcmBase
    def notificable
      order
    end

    def order
      params[:order]
    end

    def extra_payload
      {
        order_number: order.number,
        title: notification_title,
        message: notification_message,
        notification_type: type

      }
    end

    def notification_title
      I18n.t('notifications.spree_cm_commissioner.order_accepted_notification.title')
    end

    def notification_message
      I18n.t('notifications.spree_cm_commissioner.order_accepted_notification.message')
    end

    def translatable_options
      {
        order_number: order.number
      }
    end

    def type
      'order_accepted_notification'
    end
  end
end
