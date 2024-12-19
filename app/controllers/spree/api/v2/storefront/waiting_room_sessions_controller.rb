# We use lambda instead of following API to generate token. Following are just sample.
#
# POST: /api/v2/storefront/waiting_room_sessions
# Response: { token: token }
module Spree
  module Api
    module V2
      module Storefront
        class WaitingRoomSessionsController < ::Spree::Api::V2::ResourceController
          skip_before_action :ensure_waiting_room_session_token

          def create
            context = SpreeCmCommissioner::WaitingRoomSessionCreator.call(
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
            SpreeCmCommissioner::V2::Storefront::WaitingRoomSessionSerializer
          end
        end
      end
    end
  end
end
