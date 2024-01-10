module Spree
  module Api
    module V2
      module Storefront
        class GuestQrsController < ::Spree::Api::V2::ResourceController
          include ActionController::MimeResponds

          before_action :require_spree_current_user
          before_action :load_guest, only: [:show]

          def show
            respond_to do |format|
              format.png { send_data @guest.generate_png_qr, type: 'image/png', disposition: 'inline' }
              format.svg { send_data @guest.generate_svg_qr, type: 'image/svg+xml', disposition: 'inline' }
            end
          end

          private

          def load_guest
            @guest = SpreeCmCommissioner::Guest.find(params[:id])
          end
        end
      end
    end
  end
end
