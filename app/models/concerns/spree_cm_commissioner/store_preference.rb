module SpreeCmCommissioner
  module StorePreference
    extend ActiveSupport::Concern

    included do
      preference :telegram_order_alert_chat_id, :string
    end
  end
end
