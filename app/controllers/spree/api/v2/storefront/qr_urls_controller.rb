module Spree
  module Api
    module V2
      module Storefront
        class QrUrlsController < ::Spree::Api::V2::ResourceController
          UrlResource = Struct.new(:id, :url)

          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::QrUrlSerializer
          end

          def show
            resource = UrlResource.new(params[:id], guest_card_url(params[:id]))
            render_serialized_payload { serialize_resource(resource) }
          end

          private

          def guest_card_url(qr_data)
            # currently only support guest QR
            guest = SpreeCmCommissioner::Guest.find_by!(token: qr_data)

            host = ENV.fetch('CDN_CONTENT_HOST', Rails.application.routes.default_url_options[:host])
            port = Rails.application.routes.default_url_options[:port]

            Rails.application.routes.url_helpers.guest_cards_url(guest.token, host: host, port: port)
          end
        end
      end
    end
  end
end
