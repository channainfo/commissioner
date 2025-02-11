FactoryBot.define do
  factory :cm_country, class: Spree::Country do
    iso { generate(:cm_iso) }
    iso3 { generate(:cm_iso3) }
    iso_name { generate(:cm_iso_name) }
    name { 'United States' }
  end

  sequence(:cm_iso) { |n| "US#{n}" }
  sequence(:cm_iso3) { |n| "USA#{n}" }
  sequence(:cm_iso_name) { |n| "United States of America #{n}" }
end
