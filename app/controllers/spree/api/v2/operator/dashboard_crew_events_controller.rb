module Spree
  module Api
    module V2
      module Operator
        class DashboardCrewEventsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def collection
            SpreeCmCommissioner::DashboardCrewEventQuery.new(
              user_id: spree_current_user.id,
              section: params[:section] || 'incoming'
            ).events
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Operator::DashboardCrewEventSerializer
          end
        end
      end
    end
  end
end
