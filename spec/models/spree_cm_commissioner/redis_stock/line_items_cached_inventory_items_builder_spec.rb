require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::LineItemsCachedInventoryItemsBuilder do
  let(:product) { create(:cm_product, product_type: :accommodation) }
  let(:variant) { create(:cm_variant, product: product, total_inventory: 10, pregenerate_inventory_items: true, pre_inventory_days: 3) }

  describe '#call' do
    let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow + 3) }
    let(:inventory_items) { variant.reload.inventory_items }

    before do
      SpreeCmCommissioner.redis_pool.with do |redis|
        redis.mapped_mset({
          "inventory:#{inventory_items[0].id}": 3,
          "inventory:#{inventory_items[1].id}": 5,
          "inventory:#{inventory_items[2].id}": 7,
        })
      end
    end

    it 'return inventory keys & group by :line_item_id' do
      result = described_class.new(line_item_ids: [line_item.id]).call

      expect(result.keys).to eq([line_item.id])
      expect(result[line_item.id].map(&:to_h)).to eq([
        {:inventory_key => "inventory:#{inventory_items[0].id}", active: true, :quantity_available => 3, :inventory_item_id => inventory_items[0].id, :variant_id => variant.id},
        {:inventory_key => "inventory:#{inventory_items[1].id}", active: true, :quantity_available => 5, :inventory_item_id => inventory_items[1].id, :variant_id => variant.id},
        {:inventory_key => "inventory:#{inventory_items[2].id}", active: true, :quantity_available => 7, :inventory_item_id => inventory_items[2].id, :variant_id => variant.id},
      ])
    end
  end
end
