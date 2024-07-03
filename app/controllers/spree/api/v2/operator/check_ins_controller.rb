module Spree
  module Api
    module V2
      module Operator
        class CheckInsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user, only: %i[index create]

          def collection
            @collection = SpreeCmCommissioner::CheckIn.where(checkinable: params[:taxon_id])

            @collection = @collection.page(params[:page]).per(params[:per_page])
          end

          def create
            spree_authorize! :create, model_class

            context = SpreeCmCommissioner::CheckInBulkCreator.call(
              check_ins_attributes: [{ guest_id: guest_id }],
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
