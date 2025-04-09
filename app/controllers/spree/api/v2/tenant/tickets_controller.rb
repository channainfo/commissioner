module Spree
  module Api
    module V2
      module Tenant
        class TicketsController < BaseController
          def index
            render_serialized_payload do
              serialize_collection(paginated_collection)
            end
          end

          def collection
            SpreeCmCommissioner::TicketsSearcherQuery.new(params, MultiTenant.current_tenant_id).call
          end

          private

          def collection_serializer
            Spree::V2::Tenant::TicketSerializer
          end
        end
      end
    end
  end
end
