module SpreeCmCommissioner
  class LineItemJwtToken
    def self.encode(line_item)
      payload = { order_number: line_item.order.number, line_item_id: line_item.id, exp: 1.hour.from_now.to_i }
      JWT.encode(payload, line_item.order.token, 'HS256')
    end

    def self.decode(token, secret = nil)
      JWT.decode(token, secret, secret.present?, { algorithm: 'HS256' }).first
    rescue JWT::DecodeError
      nil
    end
  end
end
