module SpreeCmCommissioner
  module JwtToken
    def encode(payload, token)
      JWT.encode(payload, token, 'HS256')
    end

    def decode(token, secret = nil)
      JWT.decode(token, secret, secret.present?, { algorithm: 'HS256' }).first
    rescue JWT::DecodeError
      nil
    end
  end
end
