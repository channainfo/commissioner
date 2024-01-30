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

    trait :adults do
      name { 'adults' }
      presentation { 'Adults' }
    end

    trait :kids do
      name { 'kids' }
      presentation { 'Kids' }
    end

    trait :kids_age_max do
      name { 'kids-age-max' }
      presentation { 'Kids age max' }
    end

    initialize_with { Spree::OptionType.where(name: name).first_or_initialize }
  end
end
