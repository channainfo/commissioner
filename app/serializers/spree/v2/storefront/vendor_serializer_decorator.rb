module Spree
  module V2
    module Storefront
      module VendorSerializerDecorator
        def self.prepended(base)
          base.attributes :min_price, :max_price, :total_inventory

          base.attribute :day do |vendor|
            vendor.respond_to?(:day) ? vendor.day : nil
          end

          base.attribute :total_booking do |vendor|
            vendor.respond_to?(:total_booking) ? vendor.total_booking : 0
          end

          base.attribute :remaining do |vendor|
            vendor.respond_to?(:remaining) ? vendor.remaining : vendor.total_inventory
          end

          base.has_many :stock_locations
          base.has_many :photos, serializer: :vendor_photo

          base.has_one :logo, serializer: :vendor_logo
          base.has_one :state
        end
      end
    end
  end
end

Spree::V2::Storefront::VendorSerializer.prepend Spree::V2::Storefront::VendorSerializerDecorator
