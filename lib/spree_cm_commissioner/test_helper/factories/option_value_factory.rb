FactoryBot.define do
  factory :cm_option_value, class: Spree::OptionValue do
    option_type
    sequence(:name) { |n| "Size-#{n}" }
    presentation    { 'S' }

    to_create do |instance|
      Spree::OptionValue.first_or_initialize(name: instance.name) do |object|
        object.attributes = instance.attributes
        object.save
      end
    end
  end
end
