module SpreeCmCommissioner
  module StorePreference
    extend ActiveSupport::Concern

    included do
      preference :telegram_order_alert_chat_id, :string
      preference :telegram_order_request_alert_chat_id, :string
    end
  end
end
