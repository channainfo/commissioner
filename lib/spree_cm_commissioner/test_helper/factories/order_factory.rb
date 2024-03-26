FactoryBot.define do
  factory :transit_order, class: Spree::Order do
    bill_address
    ship_address
    state {'complete'}
    payment_state {'paid'}

    transient do
      line_items_count       { 1 }
      shipment_cost          { 100 }
      shipping_method_filter { Spree::ShippingMethod::DISPLAY_ON_FRONT_END }
      seats {}
      variant {}
      quantity {}
      date { Date.today }
    end

    after(:create) do |order, evaluator|
      if evaluator.quantity.nil? && evaluator.seats.present?
        create(:line_item, order: order, variant: evaluator.variant, date: evaluator.date, booking_seats: evaluator.seats)
        order.line_items.reload
      else
        create(:line_item, order: order, variant: evaluator.variant, date: evaluator.date, quantity: evaluator.quantity)
      end

      stock_location = order.line_items&.first&.variant&.stock_items&.first&.stock_location || create(:stock_location)
      create(:shipment, order: order, cost: evaluator.shipment_cost, stock_location: stock_location)
      order.shipments.reload

      order.update_with_updater!
    end
  end
end
