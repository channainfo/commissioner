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
      selected_seats {[]}
      line_item_seats_attributes{[]}
    end

    after(:create) do |order, evaluator|
      stock_location = evaluator.variant.stock_items.first&.stock_location || create(:stock_location)
      stock_item = Spree::StockItem.find_or_create_by(variant: evaluator.variant)
      stock_item.adjust_count_on_hand(20)

      if evaluator.quantity.nil? && evaluator.seats.present?
        line_item_seats_attributes = evaluator.seats.map do |seat|
          { seat_id: seat.id, date: evaluator.date, variant_id: evaluator.variant.id }
        end

        create(:line_item,
          order: order,
          variant: evaluator.variant,
          date: evaluator.date,
          quantity: evaluator.seats.size,
          line_item_seats_attributes: line_item_seats_attributes
        )
      else
        create(:line_item,
          order: order,
          variant: evaluator.variant,
          date: evaluator.date,
          quantity: evaluator.quantity || 1
        )
      end

      create(:shipment, order: order, cost: evaluator.shipment_cost, stock_location: stock_location)
      order.reload.update_with_updater!
    end
  end
end
