module SpreeCmCommissioner
  module WaitingRoomAuthorization
    extend ActiveSupport::Concern

    included do
      rescue_from JWT::ExpiredSignature, with: :handle_waiting_room_session_token_error
      rescue_from JWT::VerificationError, with: :handle_waiting_room_session_token_error
      rescue_from JWT::DecodeError, with: :handle_waiting_room_session_token_error

      before_action :ensure_waiting_room_session_token
    end

    def ensure_waiting_room_session_token
      # let old app version use all APIs for now if even no session token is passed.
      # additional, some API like orders, line items,... should still be allowed
      # even this is not pass to let user get their tickets.
      return if params[:waiting_room_session_token].blank?

      JWT.decode(params[:waiting_room_session_token], ENV.fetch('WAITING_ROOM_SIGNATURE'), true, { algorithm: 'HS256' })
    end

    def handle_waiting_room_session_token_error
      render_error_payload(exception.message, 400)
    end
  end
end
