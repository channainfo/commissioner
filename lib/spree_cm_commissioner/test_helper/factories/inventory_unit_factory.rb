FactoryBot.define do
  factory :cm_inventory_unit, class: SpreeCmCommissioner::InventoryUnit do
    variant { create(:variant) }
    max_capacity { 10 }
    quantity_available { 10 }
    service_type { 'accommodation' }
    inventory_date { Date.today }
  end
end
