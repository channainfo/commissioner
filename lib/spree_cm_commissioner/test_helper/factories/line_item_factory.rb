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

    variant { product.master }

    factory :cm_need_confirmation_line_item do
      product { create(:product, need_confirmation: true) }
    end
  end
end
