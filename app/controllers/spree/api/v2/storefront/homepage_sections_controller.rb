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

          def collection
            @collection ||= model_class.filter_by_segment(params[:homepage_id] || :general)
                                       .active
                                       .where(tenant_id: nil)
                                       .order(position: :asc)
          end
        end
      end
    end
  end
end
