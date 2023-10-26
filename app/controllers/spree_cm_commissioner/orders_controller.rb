class SpreeCmCommissioner::OrdersController < Spree::BaseController
  layout 'spree_cm_commissioner/layouts/order_mailer'
  helper 'spree/mail'

  def show
    @order = Spree::Order.search_by_qr_data(params[:id])
    @product_type = @order.products.first&.product_type || 'accommodation'

    render :template => 'spree/order_mailer/confirm_email'
  end
end
