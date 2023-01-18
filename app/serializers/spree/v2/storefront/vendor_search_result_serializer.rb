module Spree
  module V2
    module Storefront
      class VendorSearchResultSerializer < VendorSerializer
        has_one :state

        attributes :total_inventory

        attribute :day do |vendor|
          vendor.respond_to?(:day) ? vendor.day : nil
        end

        attribute :total_booking do |vendor|
          vendor.respond_to?(:total_booking) ? vendor.total_booking : 0
        end

        attribute :remaining do |vendor|
          vendor.respond_to?(:remaining) ? vendor.remaining : vendor.total_inventory
        end
      end
    end
  end
end