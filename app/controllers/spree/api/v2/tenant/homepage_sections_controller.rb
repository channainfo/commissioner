module Spree
  module Api
    module V2
      module Tenant
        class HomepageSectionsController < BaseController
          def collection
            @collection ||= scope.filter_by_segment(params[:homepage_id] || :general)
                                 .active
                                 .order(position: :asc)
          end

          def scope
            MultiTenant.with(@tenant) do
              model_class
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
