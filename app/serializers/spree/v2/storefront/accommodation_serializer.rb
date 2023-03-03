module Spree
  module V2
    module Storefront
      class AccommodationSerializer < VendorSerializer
        has_one :state

        has_many :pricing_rules, serializer: SpreeCmCommissioner::V2::Storefront::VendorPricingRuleSerializer
        has_many :active_pricing_rules, serializer: SpreeCmCommissioner::V2::Storefront::VendorPricingRuleSerializer

        attributes :total_inventory

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
