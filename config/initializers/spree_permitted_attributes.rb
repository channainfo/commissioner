module Spree
  module PermittedAttributes
    @@vendor_attributes << :logo

    @@line_item_attributes += %i[
      from_date
      to_date
      line_item_seats_attributes
      date
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
      confirm_pin_code_enabled
      confirm_pin_code
    ]

    @@taxon_attributes += %i[
      category_icon
      custom_redirect_url
      to_date
      from_date
      kind
      subtitle
      preferred_background_color
      preferred_foreground_color
      show_badge_status
      purchasable_on
      available_on
      hide_video_banner
      vendor_id
    ]

    @@store_attributes += [
      :preferred_telegram_order_alert_chat_id,
      :preferred_telegram_order_request_alert_chat_id,
      { default_notification_image_attributes: {} },
      :term_and_condition_promotion
    ]

    @@checkout_attributes += %i[
      channel
      phone_number
      country_code
    ]

    @@address_attributes += %i[
      age
      gender
    ]
  end
end
