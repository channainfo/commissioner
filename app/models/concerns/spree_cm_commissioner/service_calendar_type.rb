module SpreeCmCommissioner
  module ServiceCalendarType
    extend ActiveSupport::Concern

    SERVICE_TYPES = {available: true, not_available: false}.freeze

    included do
      enum service_type: SERVICE_TYPES
    end
  end
end