module SpreeCmCommissioner
  module Orders
    module FindCurrentDecorator
      def self.prepended(_base)
        private

        def incomplete_orders
          Spree::Order.incomplete.not_canceled.order(created_at: :desc)
        end
      end
    end
  end
end

unless Spree::Orders::FindCurrent.included_modules.include?(SpreeCmCommissioner::Orders::FindCurrentDecorator)
  Spree::Orders::FindCurrent.prepend(SpreeCmCommissioner::Orders::FindCurrentDecorator)
end
