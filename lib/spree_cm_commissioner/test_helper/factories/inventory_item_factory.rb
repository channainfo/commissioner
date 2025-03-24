FactoryBot.define do
  factory :cm_inventory_item, class: SpreeCmCommissioner::InventoryItem do
    variant { create(:variant) }
    max_capacity { 10 }
    quantity_available { 10 }
    product_type { 'accommodation' }
    inventory_date { Date.today }
  end
end
