module SpreeCmCommissioner
  module VendorPreference
    extend ActiveSupport::Concern

    TELEGRAM_CHAT_TYPE = %i[channel group].freeze

    included do
      preference :telegram_chat_id, :string
      preference :telegram_chat_name, :string
      preference :telegram_chat_type, :string
    end
  end
end
