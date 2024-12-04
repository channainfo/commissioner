module SpreeCmCommissioner
  class OrderJwtToken
    def self.encode(order)
      payload = { order_number: order.number, user_id: order.user_id, exp: 1.hour.from_now.to_i }
      JWT.encode(payload, order.token, 'HS256')
    end

    def self.decode(token, secret = nil)
      JWT.decode(token, secret, secret.present?, { algorithm: 'HS256' }).first
    rescue JWT::DecodeError
      nil
    end
  end
end
