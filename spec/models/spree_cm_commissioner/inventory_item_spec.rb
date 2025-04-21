require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryItem, type: :model do
  # Constants
  it 'defines the correct service types' do
    expect(SpreeCmCommissioner::InventoryItem::PRODUCT_TYPES).to eq(['accommodation', 'event', 'bus'])
  end

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
    variant = create(:variant)
    create(:cm_inventory_item, variant_id: variant.id, inventory_date: '2025-03-06')

    subject = build(:cm_inventory_item, variant_id: variant.id, inventory_date: '2025-03-06')
    expect(subject).not_to be_valid
    expect(subject.errors[:variant_id]).to include('The variant is taken on 2025-03-06')
  end

  # Scopes
  describe '.for_product' do
    let!(:accommodation_inventory_item) { create(:cm_inventory_item, product_type: 'accommodation') }
    let!(:event_inventory_item) { create(:cm_inventory_item,  product_type: 'ecommerce') }

    it 'returns inventory units for the given service type' do
      expect(SpreeCmCommissioner::InventoryItem.for_product('accommodation')).to include(accommodation_inventory_item)
      expect(SpreeCmCommissioner::InventoryItem.for_product('accommodation')).not_to include(event_inventory_item)
    end
  end

  describe '.active' do
    let!(:variant) { create(:variant) }
    let!(:past_inventory) { described_class.create!(product_type: :transit, inventory_date: 2.days.ago, variant: variant) }
    let!(:today_inventory) { described_class.create!(product_type: :transit, inventory_date: Time.zone.today, variant: variant) }
    let!(:future_inventory) { described_class.create!(product_type: :transit, inventory_date: 2.days.from_now, variant: variant) }
    let!(:normal_inventory) { described_class.create!(product_type: :ecommerce, inventory_date: nil, variant: variant) }

    it 'includes items with nil or future/today inventory_date' do
      result = described_class.active
      expect(result).to include(normal_inventory, today_inventory, future_inventory)
      expect(result).not_to include(past_inventory)
    end
  end

  describe '#adjust_quantity!' do
    let(:inventory_item) do
      described_class.create!(
        variant: create(:variant),
        product_type: :ecommerce,
        max_capacity: 10,
        quantity_available: 5,
        inventory_date: nil
      )
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
  end
end
