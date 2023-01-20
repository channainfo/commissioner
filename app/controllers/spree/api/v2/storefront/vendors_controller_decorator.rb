module Spree
  module Api
    module V2
      module Storefront
        module VendorsControllerDecorator
          def self.prepended(base)
            base.before_action :load_vendor, only: [:profile]
          end

          def profile
            render_serialized_payload { serialize_profile(@vendor) }
          end

          private
          def load_vendor
            @vendor ||= SpreeCmCommissioner::VendorDetail.call(params: params).vendor
          end

          def serialize_profile(vendor)
            Spree::V2::Storefront::VendorSearchResultSerializer.new(vendor,
              params: serializer_params,
              include: resource_includes,
              fields: sparse_fields
            ).serializable_hash
          end
        end
      end
    end
  end
end

Spree::Api::V2::Storefront::VendorsController.prepend Spree::Api::V2::Storefront::VendorsControllerDecorator
