module Spree
  module Api
    module V2
      module Storefront
        class HomepageSectionsController < ::Spree::Api::V2::ResourceController
          def model_class
            SpreeCmCommissioner::HomepageSection
          end

          def collection
            model_class.active
          end

          def collection_serializer
            Spree::V2::Storefront::HomepageSectionSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::HomepageSectionSerializer
          end
        end
      end
    end
  end
end
