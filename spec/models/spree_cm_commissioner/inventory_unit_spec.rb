require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryUnit, type: :model do
  # Constants
  it 'defines the correct service types' do
    expect(SpreeCmCommissioner::InventoryUnit::SERVICE_TYPES).to eq(['accommodation', 'event', 'bus'])
  end

  # Associations
  it { should belong_to(:variant).class_name('Spree::Variant') }

  # Validations
  it { should validate_numericality_of(:quantity_available).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:max_capacity).is_greater_than_or_equal_to(0) }

  context 'when service_type is not event' do
    subject { build(:cm_inventory_unit, service_type: 'accommodation', inventory_date: nil) }

    it 'is not valid without inventory_date' do
      expect(subject).not_to be_valid
      expect(subject.errors[:inventory_date]).to include("can't be blank")
    end
  end

  it 'validates uniqueness of variant_id scoped to inventory_date' do
    variant = create(:variant)
    create(:cm_inventory_unit, variant_id: variant.id, inventory_date: '2025-03-06')

    subject = build(:cm_inventory_unit, variant_id: variant.id, inventory_date: '2025-03-06')
    expect(subject).not_to be_valid
    expect(subject.errors[:variant_id]).to include('The variant is taken on 2025-03-06')
  end

  # Scopes
  describe '.for_service' do
    let!(:accommodation_inventory_unit) { create(:cm_inventory_unit, service_type: 'accommodation') }
    let!(:event_inventory_unit) { create(:cm_inventory_unit,  service_type: 'event') }

    it 'returns inventory units for the given service type' do
      expect(SpreeCmCommissioner::InventoryUnit.for_service('accommodation')).to include(accommodation_inventory_unit)
      expect(SpreeCmCommissioner::InventoryUnit.for_service('accommodation')).not_to include(event_inventory_unit)
    end
  end
end
