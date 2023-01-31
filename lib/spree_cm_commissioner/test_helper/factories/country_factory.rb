FactoryBot.define do
  factory :cm_country, class: Spree::Country do
    sequence(:iso_name) { |n| "ISO_NAME_#{n}" }
    sequence(:name) { |n| "NAME_#{n}" }
    sequence(:iso) { |n| "I#{n}" }
    sequence(:iso3) { |n| "IS#{n}" }
    numcode { 116 }
  end
end
