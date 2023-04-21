module Spree
  module Billing
    class InvoiceController < Spree::Billing::BaseController
      include Spree::Billing::OrderParentsConcern

      def show
        @invoice = @order.invoice
      end

      def create
        SpreeCmCommissioner::InvoiceCreator.call(order: @order)
        redirect_back fallback_location: admin_path
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
