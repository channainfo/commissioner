module Spree
  module Api
    module V2
      module Storefront
        class ActiveHomepageEventsController < Spree::Api::V2::ResourceController
          private

          def collection
            @collection ||= model_class.active_homepage_events
          end

          def model_class
            Spree::Taxon
          end

          def collection_serializer
            Spree::V2::Storefront::ActiveHomepageEventSerializer
          end
        end
      end
    end
  end
end
