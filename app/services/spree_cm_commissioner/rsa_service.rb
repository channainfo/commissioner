require 'base64'
require 'openssl'

module SpreeCmCommissioner
  class RsaService
    def initialize(private_key: nil, public_key: nil)
      @private_key = private_key
      @public_key = public_key
    end

    def sign(data)
      raise 'Private key is required to sign data' unless @private_key

      private_key_object = OpenSSL::PKey::RSA.new(@private_key)
      signature = private_key_object.sign(OpenSSL::Digest.new('SHA256'), data)
      "#{data}.#{Base64.strict_encode64(signature)}"
    end

    def verify(data, signature)
      raise 'Public key is required to verify signature' unless @public_key

      public_key_object = OpenSSL::PKey::RSA.new(@public_key)
      signature_bytes = Base64.decode64(signature)
      public_key_object.verify(OpenSSL::Digest.new('SHA256'), signature_bytes, data)
    end
  end
end
