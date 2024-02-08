module Spree
  module Api
    module V2
      module Storefront
        class HomepageSectionsController < ::Spree::Api::V2::ResourceController
          def model_class
            SpreeCmCommissioner::HomepageSection
          end

          def collection_serializer
            Spree::V2::Storefront::HomepageSectionSerializer
          end

          def resource_serializer
            Spree::V2::Storefront::HomepageSectionSerializer
          end

          def collection_finder
            SpreeCmCommissioner::HomepageSections::Find.new(scope: model_class.all, params: finder_params).execute
          end

          def collection
            @collection ||= collection_finder
          end
        end
      end
    end
  end
end
