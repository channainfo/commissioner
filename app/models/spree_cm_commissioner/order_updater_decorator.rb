module SpreeCmCommissioner
  module OrderUpdaterDecorator
    # override
    def update
      super

      # After the order is updated including item_count column
      update_user_cart_item_count
    end

    # override
    def update_item_total
      order.item_total = line_items.sum(&:amount)
      update_order_total
    end

    private

    def update_user_cart_item_count
      SpreeCmCommissioner::UserCartItemCountUpdater.new.call(order: order)
    end
  end
end

unless Spree::OrderUpdater.included_modules.include?(SpreeCmCommissioner::OrderUpdaterDecorator)
  Spree::OrderUpdater.prepend SpreeCmCommissioner::OrderUpdaterDecorator
end
