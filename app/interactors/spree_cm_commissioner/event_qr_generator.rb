module SpreeCmCommissioner
  class EventQrGenerator < BaseInteractor
    delegate :operator, :event, :expired_in_mn, to: :context

    EventQrStruct = Struct.new(
      :id,
      :qr_data,
      :expired_at
    )

    def call
      context.event_qr = EventQrStruct.new(operator.id, jwt_token, Time.zone.at(exp))
    end

    def exp
      context.exp ||= expired_in_mn.minutes.from_now.to_i
    end

    def jwt_token
      payload = { event_id: event.id, operator_id: operator.id, exp: exp }

      context.jwt_token ||= JWT.encode(
        payload,
        operator.secure_token,
        'HS256'
      )
    end
  end
end
