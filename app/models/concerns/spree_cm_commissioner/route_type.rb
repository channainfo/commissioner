module SpreeCmCommissioner
  module RouteType
    extend ActiveSupport::Concern

    ROUTE_TYPES = %i[bus subway rails ferry].freeze

    included do
      enum route_type: ROUTE_TYPES if table_exists? && column_names.include?('route_type')
    end
  end
end
