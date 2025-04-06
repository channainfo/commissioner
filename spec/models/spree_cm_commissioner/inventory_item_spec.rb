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
    let!(:event_inventory_item) { create(:cm_inventory_item,  product_type: 'event') }

    it 'returns inventory units for the given service type' do
      expect(SpreeCmCommissioner::InventoryItem.for_product('accommodation')).to include(accommodation_inventory_item)
      expect(SpreeCmCommissioner::InventoryItem.for_product('accommodation')).not_to include(event_inventory_item)
    end
  end
end
