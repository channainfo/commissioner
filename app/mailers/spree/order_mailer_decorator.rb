module Spree
  module OrderMailerDecorator
    def confirm_email(order, resend: false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      return false if @order.email.blank?

      current_store = @order.store
      @product_type = order.products.first.product_type

      subject = subject_title(resend, @order.number)

      mail(to: @order.email, from: from_address, subject: subject, store_url: current_store.url) do |format|
        format.html { render layout: 'spree_cm_commissioner/layouts/order_mailer' }
        format.text
      end
    end

    private

    def subject_title(resend, order_number)
      title = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      title += (@product_type == 'ecommerce' ? "BookMe+ Booking Confirmation ##{order_number}" : "Confirmation for Booking ID ##{order_number}")
      title
    end
  end
end

Spree::OrderMailer.prepend(Spree::OrderMailerDecorator)
