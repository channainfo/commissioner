FactoryBot.define do
  factory :cm_permission, class: SpreeCmCommissioner::Permission do
    entry { "spree/admin/merchant/orders" }
    action { "index" }
  end
end
