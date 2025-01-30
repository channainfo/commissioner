module SpreeCmCommissioner
  module Billing
    module MonthlyOrdersHelper
      def initialize_monthly_order_hashes
        {
          orders: Hash.new(0),
          total: Hash.new(0),
          paid: Hash.new(0),
          balance_due: Hash.new(0),
          voided: Hash.new(0),
          previous_month_carried_forward: Hash.new(0),
          current_month_total: Hash.new(0)
        }
      end

      def load_orders_by_month(search, year)
        hashes = initialize_monthly_order_hashes

        (1..12).each do |month|
          load_monthly_orders(search, hashes, month, year)
        end

        hashes
      end

      private

      def load_monthly_orders(search, hashes, month, year)
        hashes[:orders][month] = find_orders_for_month(search, month)
        update_monthly_sums(hashes, month)
        hashes[:previous_month_carried_forward][month] = calculate_carried_forward(search, hashes, month, year)
        hashes[:current_month_total][month] = calculate_current_month_total(hashes, month)
      end

      def find_orders_for_month(search, month)
        search.joins(:invoice).where('EXTRACT(MONTH FROM cm_invoices.date) = ?', month)
      end

      def update_monthly_sums(hashes, month)
        hashes[:total][month] = Spree::Money.new(hashes[:orders][month].sum(:total)).to_s
        hashes[:paid][month] = Spree::Money.new(hashes[:orders][month].where(payment_state: :paid).sum(:total)).to_s
        hashes[:balance_due][month] = Spree::Money.new(hashes[:orders][month].where(payment_state: :balance_due).sum(:total)).to_s
        hashes[:voided][month] = Spree::Money.new(hashes[:orders][month].where(payment_state: :failed).sum(:total)).to_s
      end

      def calculate_carried_forward(search, hashes, month, year)
        previous_month_orders = if month == 1
                                  search.joins(:invoice).where(
                                    'EXTRACT(YEAR FROM cm_invoices.date) = ? AND EXTRACT(MONTH FROM cm_invoices.date) = ?', year.to_i - 1, 12
                                  )
                                else
                                  hashes[:orders][month - 1]
                                end

        Spree::Money.new(previous_month_orders.sum(&:outstanding_balance)).to_s
      end

      def calculate_current_month_total(hashes, month)
        previous_balance = hashes[:previous_month_carried_forward][month].to_f
        current_total = hashes[:orders][month].sum(:total)

        Spree::Money.new([current_total - previous_balance, 0].max).to_s
      end
    end
  end
end
