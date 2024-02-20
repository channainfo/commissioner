module Spree
  module Api
    module V2
      module Operator
        class CheckInBulksController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user, only: [:create]

          def show
            spree_authorize! :read, model_class

            render_serialized_payload(200) do
              resource_serializer.new(
                SpreeCmCommissioner::CheckIn.where(event_id: filter_param),
                { include: resource_includes }
              ).serializable_hash
            end
          end

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

          def filter_param
            params[:event_id]
          end

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
