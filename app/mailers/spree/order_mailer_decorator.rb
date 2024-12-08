module Spree
  module OrderMailerDecorator
    # overrided
    def cancel_email(order, resend: false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      return false if @order.email.blank?

      super
    end

    def confirm_email(order, resend: false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      return false if @order.email.blank?

      @current_store = @order.store
      @product_type = @order.products.first&.product_type || 'accommodation'

      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{@current_store&.name} Booking Confirmation ##{@order.number}"

      @jwt_token = SpreeCmCommissioner::OrderJwtToken.encode(@order)

      mail(to: @order.email, from: from_address, subject: subject, store_url: @current_store.url) do |format|
        format.html { render layout: 'spree_cm_commissioner/layouts/order_mailer' }
        format.text
      end
    end

    def ticket_email(guest, email)
      @guest = guest
      @event = @guest.event
      @line_item = @guest.line_item
      @order = @line_item.order
      @email = email

      @current_store = @order.store
      @product_type = @line_item.product_type

      subject = "#{@current_store&.name} Booking Confirmation ##{@order.number}"

      mail(to: @email, from: from_address, subject: subject, store_url: @current_store.url) do |format|
        format.html { render layout: 'spree_cm_commissioner/layouts/line_item_mailer' }
        format.text
      end
    end
  end
end

Spree::OrderMailer.prepend(Spree::OrderMailerDecorator)
