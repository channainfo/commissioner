module SpreeCmCommissioner
  class OrderRejectedNotification < NoticedFcmBase
    def notificable
      order
    end

    def order
      params[:order]
    end

    def vendor
      order.line_items.first.vendor
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
      I18n.t('notifications.spree_cm_commissioner.order_rejected_notification.title')
    end

    def notification_message
      I18n.t('notifications.spree_cm_commissioner.order_rejected_notification.message',
             vendor_name: vendor&.name
            )
    end

    def translatable_options
      {
        order_number: order.number,
        vendor_name: vendor&.name
      }
    end

    def type
      'order_rejected_notification'
    end
  end
end
