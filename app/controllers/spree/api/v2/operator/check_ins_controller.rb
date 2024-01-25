module Spree
  module Api
    module V2
      module Operator
        class CheckInsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user, only: %i[index create]

          def create
            spree_authorize! :create, SpreeCmCommissioner::CheckIn

            guest_ids = [params[:guest_id]]
            context = SpreeCmCommissioner::CheckInBulkCreator.call(
              guest_ids: guest_ids,
              check_in_by: spree_current_user
            )

            if context.success?
              render_serialized_payload(201) { serialize_resource(context.check_ins[0]) }
            else
              render_error_payload(context.message)
            end
          end

          private

          def model_class
            SpreeCmCommissioner::CheckIn
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Operator::CheckInSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Operator::CheckInSerializer
          end
        end
      end
    end
  end
end