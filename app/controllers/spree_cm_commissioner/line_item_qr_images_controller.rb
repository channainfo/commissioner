module SpreeCmCommissioner
  class LineItemQrImagesController < ApplicationController
    def show
      line_item = Spree::LineItem.find(params[:id])

      send_data line_item.generate_png_qr(200), type: 'image/png', disposition: 'inline'
    end
  end
end
