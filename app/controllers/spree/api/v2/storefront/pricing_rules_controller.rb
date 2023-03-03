module Spree
  module Api
    module V2
      module Storefront
        class PricingRulesController < ::Spree::Api::V2::ResourceController
          before_action :load_vendor

          private

          def collection
            @collection ||= collection_finder.call(vendor: @vendor, from_date: params[:from_date], to_date: params[:to_date]).value
          end

          def load_vendor
            @vendor ||= Spree::Vendor.find_by(slug: params[:accommodation_id])
          end

          def model_class
            SpreeCmCommissioner::VendorPricingRule
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::VendorPricingRuleSerializer
          end

          def collection_finder
            SpreeCmCommissioner::AccommodationPriceRule
          end

          def serialize_collection(collection)
            collection_serializer.new(
              @collection,
              collection_options(collection).merge(params: serializer_params)
            ).serializable_hash
          end
        end
      end
    end
  end
end
