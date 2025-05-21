require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::VariantCachedInventoryItemsBuilder do
  let(:product) { create(:cm_product, product_type: :accommodation) }
  let(:variant) { create(:cm_variant, product: product, total_inventory: 10, pregenerate_inventory_items: true, pre_inventory_days: 3) }

  describe '#call' do
    let(:inventory_items) { variant.reload.inventory_items }

    before do
      SpreeCmCommissioner.redis_pool.with do |redis|
        redis.mapped_mset({
          "inventory:#{inventory_items[0].id}": 2,
          "inventory:#{inventory_items[1].id}": 5,
          "inventory:#{inventory_items[2].id}": 7,
        })
      end
    end

    it 'return inventory keys of variant.inventory_items base on checkin/checkout date' do
      result = described_class.new(variant_id: variant.id, dates: Time.zone.tomorrow..(Time.zone.tomorrow + 3)).call

      expect(result.map(&:to_h)).to eq([
        {:inventory_key => "inventory:#{inventory_items[0].id}", active: true, :quantity_available => 2, :inventory_item_id => inventory_items[0].id, :variant_id => variant.id},
        {:inventory_key => "inventory:#{inventory_items[1].id}", active: true, :quantity_available => 5, :inventory_item_id => inventory_items[1].id, :variant_id => variant.id},
        {:inventory_key => "inventory:#{inventory_items[2].id}", active: true, :quantity_available => 7, :inventory_item_id => inventory_items[2].id, :variant_id => variant.id},
      ])
    end
  end
end
