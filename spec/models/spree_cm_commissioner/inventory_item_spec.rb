require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItem, type: :model do
  # Associations
  it { should belong_to(:variant).class_name('Spree::Variant') }

  # Validations
  it { should validate_numericality_of(:quantity_available).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:max_capacity).is_greater_than_or_equal_to(0) }

  context 'when product_type is not event' do
    subject { build(:cm_inventory_item, product_type: 'accommodation', inventory_date: nil) }

    it 'is not valid without inventory_date' do
      expect(subject).not_to be_valid
      expect(subject.errors[:inventory_date]).to include("can't be blank")
    end
  end

  it 'validates uniqueness of variant_id scoped to inventory_date' do
    variant = create(:cm_variant)
    create(:cm_inventory_item, variant_id: variant.id, inventory_date: '2025-03-06')

    subject = build(:cm_inventory_item, variant_id: variant.id, inventory_date: '2025-03-06')
    expect(subject).not_to be_valid
    expect(subject.errors[:variant_id]).to include('The variant is taken on 2025-03-06')
  end

  describe '.active' do
    let!(:variant) { create(:cm_variant, pregenerate_inventory_items: false) }
    let!(:past_inventory) { described_class.create!(product_type: :transit, inventory_date: 2.days.ago, variant: variant) }
    let!(:today_inventory) { described_class.create!(product_type: :transit, inventory_date: Time.zone.today, variant: variant) }
    let!(:future_inventory) { described_class.create!(product_type: :transit, inventory_date: 2.days.from_now, variant: variant) }
    let!(:variant2) { create(:cm_variant) }
    let!(:normal_inventory) { variant2.inventory_items.last }

    it 'includes items with nil or future/today inventory_date' do
      result = described_class.active
      expect(result).to include(normal_inventory, today_inventory, future_inventory)
      expect(result).not_to include(past_inventory)
    end
  end

  describe '#active?' do
    let(:record) { described_class.new(inventory_date: inventory_date) }

    subject { record.active? }

    context 'when inventory_date is nil' do
      let(:inventory_date) { nil }
      it { expect(subject).to be true }
    end

    context 'when inventory_date is today' do
      let(:inventory_date) { Time.zone.today }
      it { expect(subject).to be true }
    end

    context 'when inventory_date is in the future' do
      let(:inventory_date) { Time.zone.today + 1.day }
      it { expect(subject).to be true }
    end

    context 'when inventory_date is in the past' do
      let(:inventory_date) { Time.zone.today - 1.day }
      it { expect(subject).to be false }
    end
  end

  describe '#adjust_quantity!' do
    let(:variant) { create(:cm_variant, pregenerate_inventory_items: false) }
    let(:inventory_item) do
      item = variant.inventory_items.first
      item.update!(product_type: :ecommerce, max_capacity: 10, quantity_available: 5)
      item
    end

    context 'when increasing quantity' do
      it 'adds to max_capacity and quantity_available' do
        expect {
          inventory_item.adjust_quantity!(3)
        }.to change { inventory_item.reload.max_capacity }.by(3)
         .and change { inventory_item.reload.quantity_available }.by(3)
      end
    end

    context 'when decreasing quantity' do
      it 'subtracts from max_capacity and quantity_available' do
        expect {
          inventory_item.adjust_quantity!(-2)
        }.to change { inventory_item.reload.max_capacity }.by(-2)
         .and change { inventory_item.reload.quantity_available }.by(-2)
      end
    end

    context 'when resulting quantity would be negative' do
      it 'raises an error due to validation' do
        expect {
          inventory_item.adjust_quantity!(-6)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    it 'calls adjust_quantity_in_redis with the provided quantity' do
      expect(inventory_item).to receive(:adjust_quantity_in_redis).with(10)
      inventory_item.adjust_quantity!(10)
    end
  end

  describe '#adjust_quantity_in_redis' do
    let(:redis) { Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0') }
    let(:redis_pool) { double('RedisPool') }
    let(:inventory_item) { create(:cm_inventory_item) }

    before do
      allow(SpreeCmCommissioner).to receive(:redis_pool).and_return(redis_pool)
      allow(redis_pool).to receive(:with).and_yield(redis)
    end

    context 'with real Redis', redis: true do
      let(:key) { "inventory:#{inventory_item.id}" }

      before do
        # Ensure SpreeCmCommissioner.redis_pool uses the real Redis instance
        allow(redis_pool).to receive(:with).and_yield(redis)
        # Clean up Redis before each test
        redis.del(key)
      end

      after do
        # Clean up Redis after each test
        redis.del(key)
      end

      context 'when redis key exists' do
        before do
          # Set an initial value in Redis
          redis.set(key, 50)
        end

        it 'increments the quantity in Redis' do
          expect {
            inventory_item.adjust_quantity_in_redis(10)
          }.to change { redis.get(key).to_i }.from(50).to(60)
        end

        it 'decreases the quantity in Redis' do
          expect {
            inventory_item.adjust_quantity_in_redis(-10)
          }.to change { redis.get(key).to_i }.from(50).to(40)
        end
      end

      context 'when redis key does not exist' do
        it 'does not create or increment the key' do
          inventory_item.adjust_quantity_in_redis(10)
          expect(redis.get(key)).to be_nil
        end
      end
    end
  end
end
