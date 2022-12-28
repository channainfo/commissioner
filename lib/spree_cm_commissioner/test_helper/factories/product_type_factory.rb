FactoryBot.define do
  factory :product_type, class: SpreeCmCommissioner::ProductType do
    sequence(:name)         { |n| "product_type_##{n}" }
    sequence(:presentation) { |n| "Product Type ##{n}"}
    enabled                       { true }
  end
end