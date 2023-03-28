FactoryBot.define do
  factory :cm_subscription, class: SpreeCmCommissioner::Subscription do
    start_date { '2022-12-25'.to_date }
    customer { create(:cm_customer) }
    variant {|s| create(:cm_subscribable_product, vendor: s.customer.vendor).variants.last }
  end
end