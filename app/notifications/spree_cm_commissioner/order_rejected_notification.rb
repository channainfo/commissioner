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
        order_id: order.id,
        order_number: order.number
      }
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
