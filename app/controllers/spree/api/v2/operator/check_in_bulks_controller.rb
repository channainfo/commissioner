module Spree
  module Api
    module V2
      module Operator
        class CheckInBulksController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user, only: [:create]

          def create
            spree_authorize! :create, SpreeCmCommissioner::CheckIn

            guest_ids = params[:guest_ids]
            context = SpreeCmCommissioner::CheckInBulkCreator.call(
              guest_ids: guest_ids,
              check_in_by: spree_current_user
            )

            if context.success?
              render_serialized_payload(201) do
                collection_serializer.new(
                  context.check_ins, { include: resource_includes }
                ).serializable_hash
              end
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
