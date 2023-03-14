FactoryBot.define do
  factory :cm_pricing_model, class: SpreeCmCommissioner::PricingModel do
    name { 'New Year 2022' }

    before(:create) do |pricing_model, _evaluator|
      if pricing_model.stores.empty?
        default_store = Spree::Store.default.persisted? ? Spree::Store.default : nil
        store = default_store || create(:store)
        pricing_model.stores << [store]
      end
    end
  end
end
