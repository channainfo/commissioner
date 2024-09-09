module SpreeCmCommissioner
  module GoogleWallets
    class BaseGenericClass
      include Rails.application.routes.url_helpers

      GOOGLE_API_ENDPOINT = 'https://walletobjects.googleapis.com/walletobjects/v1/genericClass'.freeze
      GOOGLE_OAUTH_SCOPE = 'https://www.googleapis.com/auth/wallet_object.issuer'.freeze

      def initialize(google_wallet_class)
        @google_wallet_class = google_wallet_class
      end

      # This method is to be overrided in subclasses
      def build_request_body
        raise NotImplementedError, 'build_request_body must be implemented in subclasses'

        ## Reference: https://developers.google.com/wallet/reference/rest/v1/genericclass
        ## Example of what the body should look like
        # {
        #   id: string,
        #   imageModulesData: [
        #     {
        #       mainImage: {
        #         sourceUri: {
        #           uri: 'https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/google-io-2021-card.png'
        #         },
        #         contentDescription: {
        #           defaultValue: {
        #             language: 'en-US',
        #             value: 'Google I/O 2022 Banner'
        #           }
        #         }
        #       },
        #       id: 'event_banner'
        #     }
        #   ],

        #   textModulesData: [
        #     {
        #       header: 'Gather points meeting new people at Google I/O',
        #       body: 'Join the game and accumulate points in this badge by meeting other attendees in the event.',
        #       id: 'game_overview'
        #     }
        #   ],

        #   linksModuleData: {
        #     uris: [
        #       {
        #         uri: 'https://io.google/2022/',
        #         description: 'Official I/O \'22 Site',
        #         id: 'official_site'
        #       }
        #     ]
        #   }
        # }
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
