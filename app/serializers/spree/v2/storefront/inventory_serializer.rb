module Spree
  module V2
    module Storefront
      class InventorySerializer
        include JSONAPI::Serializer

        set_id :variant_id
        attributes :variant_id, :quantity_available, :max_capacity, :inventory_date, :product_type
      end
    end
  end
end
