require 'spec_helper'

RSpec.describe SpreeCmCommissioner::RedisStock::CachedInventoryItemsBuilder do
  let(:product) { create(:cm_product, product_type: :accommodation) }
  let(:variant) { create(:cm_variant, product: product, total_inventory: 10) }

  # generate inventory items for 3 days
  before do
    allow_any_instance_of(Spree::Variant).to receive(:pre_inventory_days).and_return(3)
    SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator.call(variant_ids: [variant.id])
  end

  describe '#call' do
    let(:inventory_items) { variant.inventory_items }

    context 'when key already exist in redis' do
      before do
        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.mapped_mset({
            "inventory:#{inventory_items[0].id}": 2,
            "inventory:#{inventory_items[1].id}": 5,
            "inventory:#{inventory_items[2].id}": 7,
          })
        end
      end

      it 'return data from redis instantly' do
        result = described_class.new(inventory_items).call

        expect(result.map(&:to_h)).to eq([
          {:inventory_key => "inventory:#{inventory_items[0].id}", active: true, :quantity_available => 2, :inventory_item_id => inventory_items[0].id, :variant_id => variant.id},
          {:inventory_key => "inventory:#{inventory_items[1].id}", active: true, :quantity_available => 5, :inventory_item_id => inventory_items[1].id, :variant_id => variant.id},
          {:inventory_key => "inventory:#{inventory_items[2].id}", active: true, :quantity_available => 7, :inventory_item_id => inventory_items[2].id, :variant_id => variant.id}
        ])
      end
    end

    context 'when does not exist in redis yet' do
      before do
        SpreeCmCommissioner.redis_pool.with do |redis|
          keys = redis.keys('inventory:*')
          keys.each { |key| redis.del(key) } if keys.any?
        end
      end

      it 'return quantity_available from db & set cache to redis' do
        # redis return all nil
        result = SpreeCmCommissioner.redis_pool.with { |redis| redis.mget(["inventory:#{inventory_items[0].id}", "inventory:#{inventory_items[1].id}", "inventory:#{inventory_items[2].id}"]) }
        expect(result).to eq([nil, nil, nil])

        result = described_class.new(inventory_items).call

        # quantity_available is from db
        expect(result.map(&:to_h)).to eq([
          {:inventory_key => "inventory:#{inventory_items[0].id}", active: true, :quantity_available => 10, :inventory_item_id => inventory_items[0].id, :variant_id => variant.id},
          {:inventory_key => "inventory:#{inventory_items[1].id}", active: true, :quantity_available => 10, :inventory_item_id => inventory_items[1].id, :variant_id => variant.id},
          {:inventory_key => "inventory:#{inventory_items[2].id}", active: true, :quantity_available => 10, :inventory_item_id => inventory_items[2].id, :variant_id => variant.id},
        ])

        # it cache data from db back to redis
        result = SpreeCmCommissioner.redis_pool.with { |redis| redis.mget(["inventory:#{inventory_items[0].id}", "inventory:#{inventory_items[1].id}", "inventory:#{inventory_items[2].id}"]) }
        expect(result).to eq(["10", "10", "10"])
      end
    end
  end
end
