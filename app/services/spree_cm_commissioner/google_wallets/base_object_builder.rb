module SpreeCmCommissioner
  module GoogleWallets
    class BaseObjectBuilder
      attr_reader :line_item

      def initialize(line_item:)
        @line_item = line_item
      end

      # to be overrided
      def object; end

      def object_token
        JWT.encode(object, signing_key, 'RS256')
      end

      def iss
        credentials.client_email
      end

      def issuer_id
        ENV.fetch('ISSUER_ID', nil)
      end

      def signing_key
        OpenSSL::PKey::RSA.new(credentials.private_key)
      end

      def credentials
        Rails.application.credentials.google_wallet_service_account
      end
    end
  end
end
