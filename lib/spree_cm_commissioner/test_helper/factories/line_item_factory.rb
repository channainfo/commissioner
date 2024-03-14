FactoryBot.define do
  factory :cm_line_item, class: Spree::LineItem do
    order
    quantity { 1 }
    price    { BigDecimal('10.00') }
    currency { order.currency }

    product do
      if order&.store&.present?
        create(:cm_product_with_product_kind_option_types, stores: [order.store])
      else
        create(:cm_product_with_product_kind_option_types)
      end
    end
  end

  factory :transit_line_item, class: Spree::LineItem do
    order {}
    quantity { 1 }
    price    { BigDecimal('10.00') }
    currency { order.currency }

    trait :with_seats do
      transient do
        seats {[]}
      end
      after(:create) do |line_item, evaluator|
        evaluator.seats.each_with_index do |seat, index|
        create(:line_item_seat, line_item: line_item , seat: seat, date: evaluator.date, variant_id: evaluator.variant_id)
        line_item.line_item_seats.reload
        end
      end
    end
  end
end
