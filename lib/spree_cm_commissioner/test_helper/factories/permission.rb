FactoryBot.define do
  factory :cm_permission, class: SpreeCmCommissioner::Permission do
    entry { "spree/billing/orders" }
    action { "index" }
  end
end
