module SpreeCmCommissioner
  module ServiceCalendarType
    extend ActiveSupport::Concern

    SERVICE_TYPES = %i[unavailable available].freeze

    included do
      enum service_type: SERVICE_TYPES
    end
  end
end
