FactoryBot.define do
  factory :transit_order, class: Spree::Order do
    bill_address
    ship_address

    transient do
      line_items_count       { 1 }
      without_line_items     { false }
      shipment_cost          { 100 }
      shipping_method_filter { Spree::ShippingMethod::DISPLAY_ON_FRONT_END }
      seats {[]}
      variant {}
      date { Date.today }
    end

    after(:create) do |order, evaluator|
      unless evaluator.without_line_items
        create(:transit_line_item, order: order, variant: evaluator.variant, date: evaluator.date, quantity: evaluator.seats.count, seats: evaluator.seats)
        order.line_items.reload
      end

      stock_location = order.line_items&.first&.variant&.stock_items&.first&.stock_location || create(:stock_location)
      create(:shipment, order: order, cost: evaluator.shipment_cost, stock_location: stock_location)
      order.shipments.reload

      order.update_with_updater!
    end
  end
end
