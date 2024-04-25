FactoryBot.define do
  factory :cm_customer_taxon, class: SpreeCmCommissioner::CustomerTaxon do
    association :customer, factory: :cm_customer
    association :taxon, factory: :taxon
  end
end
