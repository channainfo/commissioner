# :spree_vendors
# :spree_products, :spree_prototypes

module SpreeCmCommissioner
  module ProductType
    extend ActiveSupport::Concern

    PRODUCT_TYPES = %i[accommodation service ecommerce transit].freeze
    PERMANENT_STOCK_PRODUCT_TYPES = %w[accommodation service transit].freeze
    PRE_INVENTORY_DAYS = { 'transit' => 90, 'accommodation' => 365, 'service' => 30 }.freeze

    included do
      enum product_type: PRODUCT_TYPES if table_exists? && column_names.include?('product_type')
      enum primary_product_type: PRODUCT_TYPES if table_exists? && column_names.include?('primary_product_type')
    end

    def permanent_stock?
      PERMANENT_STOCK_PRODUCT_TYPES.include?(product_type)
    end

    def pre_inventory_days
      PRE_INVENTORY_DAYS[product_type]
    end
  end
end
