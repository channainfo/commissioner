module Spree
  module Api
    module V2
      module Operator
        class GuestsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user

          def index
            render_serialized_payload do
              serialize_collection(paginated_collection)
            end
          end

          def collection
            SpreeCmCommissioner::GuestSearcherQuery.new(params).call
          end

          private

          def model_class
            SpreeCmCommissioner::Guest
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Operator::GuestSerializer
          end

          def collection_serializer
            SpreeCmCommissioner::V2::Operator::GuestSerializer
          end
        end
      end
    end
  end
end
