module Spree
  module Api
    module V2
      module Tenant
        class HomepageSectionsController < BaseController
          def index
            collection = model_class.filter_by_segment(params[:homepage_id] || :general)
                                    .active
                                    .order(position: :asc)
                                    .page(params[:page])
                                    .per(params[:per_page])

            render_serialized_payload do
              serialize_collection(collection)
            end
          end

          def model_class
            SpreeCmCommissioner::HomepageSection
          end

          def collection_serializer
            Spree::V2::Tenant::HomepageSectionSerializer
          end

          def resource_serializer
            Spree::V2::Tenant::HomepageSectionSerializer
          end
        end
      end
    end
  end
end
