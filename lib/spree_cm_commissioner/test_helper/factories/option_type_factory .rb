FactoryBot.define do
  factory :cm_option_type, class: Spree::OptionType do
    sequence(:name) { |n| "foo-size-#{n}" }
    presentation    { 'Size' }

    trait :month do
      name { 'month' }
      presentation { 'Month' }
    end

    trait :due_date do
      name { 'due-date' }
      presentation { 'due-date' }
    end

    trait :payment_option do
      name { 'payment-option' }
      presentation { 'payment-option' }
    end

    trait :delivery_option do
      attr_type { 'delivery_type' }
      name { 'delivery-option' }
      presentation { 'Delivery option' }
    end

    trait :adults do
      attr_type { 'integer' }
      name { 'adults' }
      presentation { 'Adults' }
    end

    trait :kids do
      attr_type { 'integer' }
      name { 'kids' }
      presentation { 'Kids' }
    end

    trait :kids_age_max do
      attr_type { 'integer' }
      name { 'kids-age-max' }
      presentation { 'Kids age max' }
    end

    trait :allowed_extra_adults do
      attr_type { 'integer' }
      name { 'allowed-extra-adults' }
      presentation { 'Allowed extra adults' }
    end

    trait :allowed_extra_kids do
      attr_type { 'integer' }
      name { 'allowed-extra-kids' }
      presentation { 'Allowed extra kids' }
    end

    trait :max_quantity_per_order do
      attr_type { 'integer' }
      name { 'max-quantity-per-order' }
      presentation { 'Max quantity per order' }
    end

    initialize_with { Spree::OptionType.where(name: name).first_or_initialize }
  end
end
