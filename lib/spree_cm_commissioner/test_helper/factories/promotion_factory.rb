FactoryBot.define do
  factory :cm_promotion, parent: :promotion do
    trait :with_vendor_rule do
      transient do
        vendor { create(:vendor) }
      end

      after(:create) do |promotion, evaluator|
        rule = SpreeCmCommissioner::Promotion::Rules::Vendors.create!(vendors: [evaluator.vendor])
        promotion.rules << rule
        promotion.save!
      end
    end
  end
end
