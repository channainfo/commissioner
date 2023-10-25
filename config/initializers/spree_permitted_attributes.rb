module Spree
  module PermittedAttributes
    @@vendor_attributes << :logo
    @@line_item_attributes += %i[from_date to_date]
    @@user_attributes      += %i[first_name last_name dob gender phone_number profile]
    @@taxon_attributes     += %i[category_icon custom_redirect_url to_date from_date kind]
    @@store_attributes     += %i[preferred_telegram_order_alert_chat_id preferred_telegram_order_request_alert_chat_id]

    @@checkout_attributes += %i[phone_number country_code]
  end
end
