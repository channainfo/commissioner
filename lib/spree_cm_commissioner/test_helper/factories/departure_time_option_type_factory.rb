FactoryBot.define do
  factory :departure_time, class: Spree::OptionType do
    name { 'departure_time' }
    attr_type { 'departure_time' }
    kind {'variant'}
    presentation { '' }
  end
end
