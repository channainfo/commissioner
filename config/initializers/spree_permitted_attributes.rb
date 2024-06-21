module Spree
  module PermittedAttributes
    @@vendor_attributes << :logo
    @@line_item_attributes += %i[
      from_date
      to_date
    ]
    @@user_attributes += %i[
      first_name
      last_name
      dob gender
      phone_number
      profile
      otp_enabled
      otp_email
      otp_phone_number
      encrypted_confirm_pin_code
    ]
    @@taxon_attributes += %i[
      category_icon
      custom_redirect_url
      to_date
      from_date
      kind
      subtitle
    ]

    @@store_attributes += [
      :preferred_telegram_order_alert_chat_id,
      :preferred_telegram_order_request_alert_chat_id,
      { default_notification_image_attributes: {} }
    ]

    @@checkout_attributes += %i[
      phone_number
      country_code
    ]
  end
end
