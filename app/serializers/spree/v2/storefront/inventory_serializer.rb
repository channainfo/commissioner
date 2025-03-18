module Spree
  module V2
    module Storefront
      class InventorySerializer
        include JSONAPI::Serializer

        set_type :inventory
        set_id :variant_id
        attributes :variant_id, :quantity_available, :max_capacity, :inventory_date, :service_type

        attribute :price do |object|
          Spree::Variant.find(object.variant_id).price
        end
      end
    end
  end
end
