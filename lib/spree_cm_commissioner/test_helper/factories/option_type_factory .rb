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

    initialize_with { Spree::OptionType.where(name: name).first_or_initialize }
  end
end
