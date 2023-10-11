class SpreeCmCommissioner::QrImagesController < ApplicationController
  def show
    order = Spree::Order.find_by!(token: params[:id])

    send_data order.generate_png_qr(200), type: 'image/png', disposition: 'inline'
  end
end
