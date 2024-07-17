module SpreeCmCommissioner
  module GoogleWallets
    class BaseHotelClass < BaseGenericClass
      def call
        response = send_request
        { status: response.code }
      end

      # This method is to be overrided in subclasses
      def send_request
        raise NotImplementedError, 'send_request must be implemented in subclasses'
      end

      def issuer_id
        ENV.fetch('ISSUER_ID', nil)
      end

      def class_id
        "#{issuer_id}.#{@google_wallet_class.class_id}"
      end

      def issuer_name
        @google_wallet_class.preferred_issuer_name
      end

      def hotel_name
        @google_wallet_class.preferred_hotel_name
      end

      def hotel_address
        @google_wallet_class.preferred_hotel_address
      end

      def background_color
        @google_wallet_class.preferred_background_color
      end

      def logo
        rails_blob_url(@google_wallet_class.logo)
      end

      def hero_image
        rails_blob_url(@google_wallet_class.hero_image)
      end

      # override
      def build_request_body
        {
          id: class_id,
          issuerId: issuer_id,
          imageModulesData: [
            {
              mainImage: {
                sourceUri: {
                  id: 'logo',
                  uri: logo
                }
              }
            }
          ],
          textModulesData: [
            {
              header: 'Hotel Name',
              body: hotel_name
            },
            {
              header: 'Hotel Address',
              body: hotel_address
            },
            {
              header: 'Background Color',
              body: background_color
            }
          ]
        }.to_json
      end
    end
  end
end
