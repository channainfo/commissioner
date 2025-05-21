module Spree
  module Api
    module V2
      module Tenant
        class WaitingRoomSessionsController < BaseController
          skip_before_action :ensure_waiting_room_session_token

          def create
            context = SpreeCmCommissioner::WaitingRoomSessionCreator.call(
              tenant_id: MultiTenant.current_tenant_id,
              remote_ip: request.remote_ip,
              waiting_guest_firebase_doc_id: params[:waiting_guest_firebase_doc_id],
              page_path: params[:page_path]
            )

            if context.success?
              render_serialized_payload { serialize_resource(context.room_session) }
            else
              render_error_payload(context.message)
            end
          end

          def resource_serializer
            Spree::V2::Tenant::WaitingRoomSessionSerializer
          end
        end
      end
    end
  end
end
