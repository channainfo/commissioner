module SpreeCmCommissioner
  class CustomerContentNotification < NoticedFcmBase
    param :customer_notification

    def image_url
      customer_notification.push_notification_image_url
    end

    # overrided
    def notificable
      customer_notification
    end

    def customer_notification
      params[:customer_notification]
    end

    def extra_payload
      {
        customer_notification_id: customer_notification.id,
        url: customer_notification.url
      }
    end

    def translatable_options
      {
        title: customer_notification.title,
        message: customer_notification.excerpt
      }
    end

    def message
      record.params[:translatable_options][:message]
    end

    def title
      record.params[:translatable_options][:title]
    end

    def type
      'customer_notification'
    end
  end
end
