module Spree
  module Billing
    class InvoiceController < Spree::Billing::BaseController
      include Spree::Billing::OrderParentsConcern
      helper SpreeCmCommissioner::Billing::QrcodesHelper

      def show
        @invoice = @order.invoice
      end

      def create
        SpreeCmCommissioner::InvoiceCreator.call(order: @order)
        redirect_back fallback_location: admin_path
      end

      # print_invoice_date_billing_order_invoice_path => /spree/orders/:order_id/invoice/print_invoice_date
      # method to record the date when the invoice was printed
      def print_invoice_date
        order.invoice.update(invoice_issued_date: Time.zone.now)
      end

      # @overrided
      def order
        @order = Spree::Order.find_by!(number: params[:order_id])
      end

      def model_class
        SpreeCmCommissioner::Invoice
      end

      def object_name
        'spree_cm_commissioner_invoice'
      end
    end
  end
end
