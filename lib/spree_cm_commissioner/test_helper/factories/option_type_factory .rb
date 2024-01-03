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

    to_create do |instance|
      Spree::OptionType.first_or_initialize(name: instance.name) do |object|
        object.attributes = instance.attributes
        object.save
      end
    end
  end
end
