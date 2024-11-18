# We use lambda instead of following API to generate token. Following are just sample.
#
# POST: /api/v2/storefront/waiting_room_sesions
# Response: { token: token }
module Spree
  module Api
    module V2
      module Storefront
        class WaitingRoomSessionsController < ::Spree::Api::V2::ResourceController
          skip_before_action :ensure_waiting_room_session_token

          def create
            payload = { exp: 1.day.from_now.to_i }
            token = JWT.encode(payload, ENV.fetch('WAITING_ROOM_SIGNATURE'), 'HS256')

            render json: { token: token }
          end
        end
      end
    end
  end
end
