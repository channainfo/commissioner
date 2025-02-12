FactoryBot.define do
  factory :duration, class: Spree::OptionType do
    name { 'duration' }
    attr_type { 'duration' }
    kind {'variant'}
    presentation { '' }
  end
end
