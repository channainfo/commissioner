FactoryBot.define do
  factory :vehicle_option_type, class: Spree::OptionType do
    name { 'vehicle_option_type' }
    attr_type { 'vehicle' }
    kind {'variant'}
    presentation { '' }
  end
end
