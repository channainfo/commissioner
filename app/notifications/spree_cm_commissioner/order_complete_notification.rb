module SpreeCmCommissioner
  class OrderCompleteNotification < NoticedFcmBase
    def notificable
      order
    end

    def order
      params[:order]
    end

    def extra_payload
      {
        order_id: order.id,
        order_number: order.number
      }
    end

    def translatable_options
      {
        order_number: order.number
      }
    end

    def type
      'order_complete_notification'
    end
  end
end
