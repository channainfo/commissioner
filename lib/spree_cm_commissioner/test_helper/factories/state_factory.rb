FactoryBot.define do
  factory :cm_state, class: Spree::State do
    sequence(:name) { |n| "STATE_NAME_#{n}" }
    sequence(:abbr) { |n| "STATE_ABBR_#{n}" }

    country { Spree::Country.first || create(:cm_country) }
  end
end
