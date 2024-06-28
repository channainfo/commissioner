module SpreeCmCommissioner
  module GoogleWallets
    class BaseEventTicketClass
      GOOGLE_API_ENDPOINT = 'https://walletobjects.googleapis.com/walletobjects/v1/eventTicketClass'.freeze
      GOOGLE_OAUTH_SCOPE = 'https://www.googleapis.com/auth/wallet_object.issuer'.freeze

      def initialize(google_wallet_class)
        @google_wallet_class = google_wallet_class
      end

      def call
        response = send_request
        { status: response.code }
      end

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

      def event_name
        @google_wallet_class.preferred_event_name
      end

      def venue_name
        @google_wallet_class.preferred_venue_name
      end

      def venue_address
        @google_wallet_class.preferred_venue_address
      end

      def background_color
        @google_wallet_class.preferred_background_color
      end

      def logo
        (vendor_logo_url.presence || @google_wallet_class.logo.original_url)
      end

      def hero_image
        @google_wallet_class.hero_image.original_url
      end

      def start_date
        date_format(@google_wallet_class.preferred_start_date)
      end

      def end_date
        date_format(@google_wallet_class.preferred_end_date)
      end

      def date_format(date)
        datetime_object = DateTime.parse(date)
        datetime_object.strftime('%Y-%m-%dT%H:%M')
      end

      def vendor_logo_url
        @google_wallet_class.product.vendor.logo&.original_url
      end

      def build_request_body
        {
          id: class_id,
          issuerName: issuer_name,
          localizedIssuerName: {
            defaultValue: {
              language: 'en-US',
              value: issuer_name
            }
          },
          eventName: {
            defaultValue: {
              language: 'en-US',
              value: event_name
            }
          },
          logo: {
            sourceUri: {
              uri: logo
            }
          },
          heroImage: {
            sourceUri: {
              uri: hero_image
            }
          },
          venue: {
            name: {
              defaultValue: {
                language: 'en-US',
                value: venue_name
              }
            },
            address: {
              defaultValue: {
                language: 'en-US',
                value: venue_address
              }
            }
          },
          dateTime: {
            start: start_date,
            end: end_date
          },
          reviewStatus: 'UNDER_REVIEW',
          hexBackgroundColor: background_color
        }.to_json
      end

      def credentials
        Rails.application.credentials.google_wallet_service_account
      end

      def access_token
        authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(credentials.to_json),
          scope: GOOGLE_OAUTH_SCOPE
        )
        authorizer.fetch_access_token!['access_token']
      end
    end
  end
end
