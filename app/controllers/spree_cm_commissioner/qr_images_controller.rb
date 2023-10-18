class SpreeCmCommissioner::QrImagesController < ApplicationController
  def show
    token = params[:id].match(/^R\d{9,}-([A-Za-z0-9_\-]+)$/)&.captures

    return unless token

    order = Spree::Order.find_by!(token: token)

    send_data order.generate_png_qr(200), type: 'image/png', disposition: 'inline'
  end
end
