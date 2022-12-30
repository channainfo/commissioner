# :spree_vendors
# :spree_products, :spree_prototypes

module SpreeCmCommissioner
  module ProductType
    extend ActiveSupport::Concern

    PRODUCT_TYPES = %i[accommodation service ecommerce]

    included do
      enum product_type: PRODUCT_TYPES if column_names.include?("product_type")
      enum primary_product_type: PRODUCT_TYPES if column_names.include?("primary_product_type")
    end
  end
end
