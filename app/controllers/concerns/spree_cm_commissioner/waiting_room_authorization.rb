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
      return if ENV['WAITING_ROOM_DISABLED'] == 'yes'
      return if request_from_client?
      return unless required_waiting_room_session?

      JWT.decode(params[:waiting_room_session_token], ENV.fetch('WAITING_ROOM_SESSION_SIGNATURE', nil), true, { algorithm: 'HS256' })
    end

    def required_waiting_room_session?
      apis = [
        '/api/v2/storefront/products',
        '/api/v2/storefront/taxons'
      ]

      apis.any? { |prefix| request.path.start_with?(prefix) }
    end

    # temporary disable session check from any client server requests.
    def request_from_client?
      request.headers['X-Cm-Api-Client-Version'].present?
    end

    def handle_waiting_room_session_token_error
      render_error_payload(Spree.t(:invalid_session_token), 400)
    end
  end
end
