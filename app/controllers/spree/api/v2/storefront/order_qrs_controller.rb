module Spree
  module Api
    module V2
      module Storefront
        class OrderQrsController < ::Spree::Api::V2::ResourceController
          include ActionController::MimeResponds

          before_action :require_spree_current_user

          def show
            order = Spree::Order.find_by(number: params[:id])

            respond_to do |format|
              format.png { send_data order.generate_png_qr, type: 'image/png', disposition: 'inline' }
              format.svg { send_data order.generate_svg_qr, type: 'image/svg+xml', disposition: 'inline' }
            end
          end
        end
      end
    end
  end
end
