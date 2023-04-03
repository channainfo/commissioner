FactoryBot.define do
  factory :cm_option_value, class: Spree::OptionValue do
    option_type
    sequence(:name) { |n| "Size-#{n}" }
    presentation    { 'S' }

    initialize_with { Spree::OptionValue.where(name: name, option_type: option_type).first_or_initialize }
  end
end
