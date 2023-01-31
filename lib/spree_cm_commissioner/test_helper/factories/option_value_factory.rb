FactoryBot.define do
  factory :cm_option_value, class: Spree::OptionValue do
    name { FFaker::Name.unique.name }
    presentation { FFaker::Name.unique.name }
    option_type
  end
end
