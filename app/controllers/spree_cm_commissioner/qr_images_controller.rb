class SpreeCmCommissioner::QrImagesController < ApplicationController
  def show
    return unless params[:id].match?(/^R\d{9}-[A-Za-z0-9\-]{35}$/)

    token = params[:id].sub(/^R\d{9}-/, '')
    order = Spree::Order.find_by!(token: token)

    send_data order.generate_png_qr(200), type: 'image/png', disposition: 'inline'
  end
end
