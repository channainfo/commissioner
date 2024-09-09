class NoticedFcmBase < Noticed::Base
  deliver_by :database, format: :format_for_database, if: :push_notificable?
  deliver_by :fcm, credentials: :fcm_credentials, format: :format_notification, if: :push_notificable?
  delegate :push_notificable?, to: :recipient

  def format_for_database
    {
      notificable: notificable,
      type: type,

      params: {
        payload: payload,
        translatable_options: translatable_options

      }
    }
  end

  def fcm_credentials
    Rails.application.credentials.google_service_account
  end

  def fcm_device_tokens(recipient)
    recipient.device_tokens.map(&:registration_token)
  end

  def format_notification(device_token)
    {
      data: convert_hash_values_to_str(payload),
      token: device_token,
      notification: {
        title: title,
        body: message
      },

      # send notication with image
      android: android_settings,
      apns: apns_settings
    }
  end

  def image_url
    nil
  end

  def android_settings
    return if image_url.nil?

    {
      notification: {
        image: image_url
      }
    }
  end

  def apns_settings
    return if image_url.nil?

    {
      payload: {
        aps: {
          'mutable-content': 1
        }
      },
      fcm_options: {
        image: image_url
      }
    }
  end

  def notificable
    raise NotImplementedError, 'Notification must implement a notificable method'
  end

  def convert_hash_values_to_str(hash)
    hash.each do |key, value|
      hash[key] = value.to_s
    end
  end

  def payload
    default_payload = {
      id: notificable.id.to_s,
      type: type
    }
    default_payload.merge(extra_payload)
  end

  def extra_payload
    {}
  end

  def translatable_options
    {}
  end

  def message
    t('.message', **(record.params[:translatable_options] || {}))
  end

  def title
    t('.title', **(record.params[:translatable_options] || {}))
  end

  def type
    self.class.to_s.underscore
  end

  # rubocop:disable Lint/UnusedMethodArgument
  def cleanup_device_token(token:, platform:)
    SpreeCmCommissioner::DeviceToken.where(registration_token: token).destroy_all
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
