# :spree_vendors
# :spree_products, :spree_prototypes

module SpreeCmCommissioner
  module ProductType
    extend ActiveSupport::Concern

    PRODUCT_TYPES = %i[accommodation service ecommerce transit event bus].freeze

    included do
      enum product_type: PRODUCT_TYPES if table_exists? && column_names.include?('product_type')
      enum primary_product_type: PRODUCT_TYPES if table_exists? && column_names.include?('primary_product_type')

      def service_type
        case product_type
        when 'event', 'ecommerce' then 'event'
        when 'bus', 'transit' then 'bus'
        when 'accommodation' then 'accommodation'
        else product_type
        end
      end
    end
  end
end
