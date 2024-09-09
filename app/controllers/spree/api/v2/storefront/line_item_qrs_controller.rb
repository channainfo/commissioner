module Spree
  module Api
    module V2
      module Storefront
        class LineItemQrsController < ::Spree::Api::V2::ResourceController
          include ActionController::MimeResponds

          before_action :require_spree_current_user
          before_action :load_line_item, only: [:show]

          def show
            respond_to do |format|
              format.png { send_data @line_item.generate_png_qr, type: 'image/png', disposition: 'inline' }
              format.svg { send_data @line_item.generate_svg_qr, type: 'image/svg+xml', disposition: 'inline' }
            end
          end

          private

          def load_line_item
            @line_item = Spree::LineItem.find_by(id: params[:id])
          end
        end
      end
    end
  end
end
