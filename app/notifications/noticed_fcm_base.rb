class NoticedFcmBase < Noticed::Base
  deliver_by :database, format: :format_for_database, if: :push_notificable?

  def push_notificable?
    recipient.device_tokens?
  end

  def format_for_database
    {
      type: self.class.name,
      notificable: notificable,
      params: {
        payload: payload,
        translatable_options: translatable_options
      }
    }
  end

  def notificable
    raise NotImplementedError, 'Notification must implement a notificable method'
  end

  def payload
    default_payload = {
      type: type,
      id: notificable.id.to_s
    }
    default_payload.merge(extra_payload)
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

  def message
    t('.message', record.params[:translatable_options] || {})
  end

  def title
    t('.title', record.params[:translatable_options] || {})
  end

  def type
    self.class.to_s.underscore
  end
end
