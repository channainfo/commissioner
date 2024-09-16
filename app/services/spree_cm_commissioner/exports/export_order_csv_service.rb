module SpreeCmCommissioner
  module Exports
    class ExportOrderCsvService
      attr_reader :orders, :customer_place_id

      def initialize(orders, customer_place_id = nil)
        @orders = orders
        @customer_place_id = customer_place_id
      end

      def call
        bom = "\uFEFF"

        bom + CSV.generate(headers: true) do |csv|
          csv << headers

          filtered_orders = if @customer_place_id.present?
                              @orders.joins(:customer).where(cm_customers: { place_id: @customer_place_id })
                            else
                              @orders
                            end

          filtered_orders.find_each do |order|
            csv << attributes(order)
          end
        end
      end

      private

      def headers
        ['Invoice Number', 'Invoice Issued Date', 'Invoice Printing Date', 'Subscription Date',
         'Customer Name', 'Customer Register Date', 'Customer Number', 'Place Name',
         'Intel Phone Number', 'Sub Total', 'Discount', 'Payment State',
         'Grand Total', 'Payment Date', 'Receiver Name'
        ]
      end

      def attributes(order)
        [
          invoice_number(order),
          invoice_issued_date(order),
          invoice_printing(order),
          subscription_date(order),
          customer_name(order),
          customer_register_date(order),
          customer_number(order),
          place_name(order),
          intel_phone_number(order),
          display_subtotal(order),
          display_discount(order),
          payment_state(order),
          display_total(order),
          payment_date(order),
          receiver_name(order)
        ]
      end

      def invoice_number(order)
        order.invoice.invoice_number
      end

      def invoice_issued_date(order)
        order.invoice.date.to_date.to_s
      end

      def invoice_printing(order)
        order.invoice.try(:invoice_issued_date)&.to_date&.to_s
      end

      def subscription_date(order)
        "#{order.line_items.first.from_date.to_date} to #{order.line_items.first.to_date.to_date}"
      end

      def customer_register_date(order)
        order.customer.created_at.to_date.to_s
      end

      def customer_number(order)
        order.customer.try(:customer_number).to_s
      end

      def intel_phone_number(order)
        order.customer.try(:intel_phone_number).to_s.gsub('855', '855 ')
      end

      def display_subtotal(order)
        order.display_item_total.to_s.gsub(',', ' ').gsub('.00', '').gsub('៛', '')
      end

      def payment_state(order)
        order.payment_state.to_s
      end

      def display_total(order)
        order.display_total.to_s.gsub(',', ' ').gsub('.00', '').gsub('៛', '')
      end

      def payment_date(order)
        order.payments.last.updated_at.to_date.to_s
      end

      def customer_name(order)
        if order.customer.first_name.present?
          order.customer.first_name.to_s.gsub(',', ' ').gsub('&', 'and')
        else
          order.customer.last_name.to_s.gsub(',', ' ').gsub('&', 'and')
        end
      end

      def receiver_name(order)
        if order.payments.last.payable.is_a?(Spree::User)
          order.payments.last.payable.full_name.to_s
        else
          ''
        end
      end

      def display_discount(order)
        if order.display_adjustment_total.to_s.include?('-')
          "-#{order.display_adjustment_total.to_s.gsub(',', ' ').gsub('.00', '').gsub('-', '').gsub('៛', '')}"
        else
          order.display_adjustment_total.to_s.gsub(',', ' ').gsub('.00', '').gsub('-', '').gsub('៛', '').to_s
        end
      end

      def place_name(order)
        order.customer.place.name.to_s.gsub(',', ' ').gsub('&', 'and')
      end
    end
  end
end
