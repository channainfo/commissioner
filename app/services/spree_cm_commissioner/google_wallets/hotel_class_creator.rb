module SpreeCmCommissioner
  module GoogleWallets
    class HotelClassCreator < BaseGenericClass
      include Rails.application.routes.url_helpers

      def call
        response = send_request
        { status: response.code }
      end

      def issuer_id
        ENV.fetch('ISSUER_ID', nil)
      end

      def class_id
        "#{issuer_id}.#{@google_wallet_class.class_id}r"
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
          classTemplateInfo: {
            cardTemplateOverride: {
              cardRowTemplateInfos: [
                {
                  twoItems: {
                    startItem: {
                      firstValue: {
                        fields: [
                          {
                            fieldPath: "object.textModulesData['points']"
                          }
                        ]
                      }
                    },
                    endItem: {
                      firstValue: {
                        fields: [
                          {
                            fieldPath: "object.textModulesData['contacts']"
                          }
                        ]
                      }
                    }
                  }
                }
              ]
            }
          },
          imageModulesData: [
            {
              mainImage: {
                sourceUri: {
                  id: 'logo',
                  uri: logo
                }
              }
            },
            {
              mainImage: {
                sourceUri: {
                  id: 'heroImage',
                  uri: hero_image
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

      # override
      def send_request
        uri = URI.parse(GOOGLE_API_ENDPOINT)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Bearer #{access_token}"
        request['Content-Type'] = 'application/json'
        request.body = build_request_body

        http.request(request)
      end
    end
  end
end
