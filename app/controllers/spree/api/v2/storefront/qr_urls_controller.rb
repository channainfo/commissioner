module Spree
  module Api
    module V2
      module Storefront
        class QrUrlsController < ::Spree::Api::V2::ResourceController
          # override
          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::QrUrlSerializer
          end

          def show
            url = find_url_by_qr_data(params[:id])
            resource = Struct.new(:id, :url).new(id: params[:id], url: url)
            render_serialized_payload { serialize_resource(resource) }
          end

          # currently only support guest QR
          def find_url_by_qr_data(qr_data)
            guest_qr_url(qr_data)
          end

          def guest_qr_url(qr_data)
            guest = SpreeCmCommissioner::Guest.find_by!(token: qr_data)

            host = Spree.cdn_host || Rails.application.routes.default_url_options[:host]
            port = Rails.application.routes.default_url_options[:port]

            Rails.application.routes.url_helpers.guest_cards_url(guest.token, host: host, port: port)
          end
        end
      end
    end
  end
end
