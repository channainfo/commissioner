FactoryBot.define do
  factory :trip_order, class: Spree::Order do
    bill_address
    ship_address
    state { 'complete' }
    payment_state { 'paid' }
    currency { 'USD' }
    completed_at { Time.current }

    transient do
      line_items_count       { 1 }
      shipment_cost          { 100 }
      shipping_method_filter { Spree::ShippingMethod::DISPLAY_ON_FRONT_END }
      blocks                 {}
      variant                {}
      quantity               {}
      date                   { Date.today }
      selected_blocks         { [] }
      line_item_blocks_attributes { [] }
    end
    after(:create) do |order, evaluator|
      quantity = evaluator.quantity || evaluator.blocks.count
      line_item = create(:line_item, order: order, variant: evaluator.variant, date: evaluator.date, quantity: quantity || 1)
      stock_location = order.line_items&.first&.variant&.stock_items&.first&.stock_location || create(:stock_location)
      create(:shipment, order: order, cost: evaluator.shipment_cost, stock_location: stock_location)
      SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator.call(variant_ids: [evaluator.variant.id])
      order.reload.update_with_updater!
    end
  end

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
      if evaluator.quantity.nil? && evaluator.seats.present?
        @line_item_seats_attributes =  evaluator.seats.map do |seat|
          {seat_id: seat.id, date: evaluator.date, variant_id: evaluator.variant.id}
        end
        create(:line_item, order: order, variant: evaluator.variant, date: evaluator.date, line_item_seats_attributes: @line_item_seats_attributes)
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
