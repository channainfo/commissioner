module SpreeCmCommissioner
  module OrderUpdaterDecorator
    # override
    def update_item_total
      order.item_total = line_items.sum(&:amount)
      update_order_total
    end
  end
end

unless Spree::OrderUpdater.included_modules.include?(SpreeCmCommissioner::OrderUpdaterDecorator)
  Spree::OrderUpdater.prepend SpreeCmCommissioner::OrderUpdaterDecorator
end
