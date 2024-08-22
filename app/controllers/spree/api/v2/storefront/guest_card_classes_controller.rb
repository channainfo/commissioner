module Spree
  module Api
    module V2
      module Storefront
        class GuestCardClassesController < Spree::Api::V2::ResourceController
          def show
            variant = Spree::Variant.find(params[:id])
            @guest_card_class = variant.guest_card_class.first

            render_serialized_payload { serialize_resource(@guest_card_class) }
          end

          private

          def model_class
            SpreeCmCommissioner::GuestCardClass
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Storefront::GuestCardClassSerializer
          end

          def resource_serializer
            if @guest_card_class.is_a?(SpreeCmCommissioner::GuestCardClasses::BibCardClass)
              SpreeCmCommissioner::V2::Storefront::BibCardClassSerializer
            else
              SpreeCmCommissioner::V2::Storefront::GuestCardClassSerializer
            end
          end
        end
      end
    end
  end
end
