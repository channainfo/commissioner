require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InventoryServices::AccommodationService do
  let(:service) { described_class.new(variant_id) }
  let(:variant_id) { nil }

  describe '#fetch_inventory' do
    let(:variant) { create(:variant) }
    let(:today) { Date.today }
    let(:tomorrow) { today + 1 }
    let(:variant_id) { variant.id }

    context 'with valid dates' do
      context 'scenario 1: 1 guest, 2 nights' do
        let!(:inventory_today) { create(:cm_inventory_unit, variant: variant, inventory_date: today, quantity_available: 2, max_capacity: 3) }
        let!(:inventory_tomorrow) { create(:cm_inventory_unit, variant: variant, inventory_date: tomorrow, quantity_available: 1, max_capacity: 3) }

        it 'returns available inventory' do
          result = service.fetch_inventory(today, tomorrow + 1, 1)
          expect(result).to be_present
          expect(result.variant_id).to eq(variant.id)
          expect(result.quantity_available).to eq(1) # Minimum available across days
        end
      end

      context 'scenario 2: 2 guests, 2 nights with insufficient availability' do
        let!(:inventory_today) { create(:cm_inventory_unit, variant: variant, inventory_date: today, quantity_available: 2, max_capacity: 2) }
        let!(:inventory_tomorrow) { create(:cm_inventory_unit, variant: variant, inventory_date: tomorrow, quantity_available: 1, max_capacity: 3) }

        it 'returns nil when quantity is insufficient' do
          result = service.fetch_inventory(today, tomorrow + 1, 2)
          expect(result).to be_nil
        end
      end
    end

    context 'with invalid dates' do
      it 'returns nil for past dates' do
        result = service.fetch_inventory(today - 1, today, 1)
        expect(result).to be_nil
      end

      it 'returns nil when check_out is before check_in' do
        result = service.fetch_inventory(tomorrow, today, 1)
        expect(result).to be_nil
      end
    end
  end

  describe '#with_available_inventory' do
    let(:variant1) { create(:variant) }
    let(:variant2) { create(:variant) }
    let(:today) { Date.today }
    let(:tomorrow) { today + 1 }

    context 'with multiple variants' do
      before do
        create(:cm_inventory_unit, variant: variant1, inventory_date: today, quantity_available: 2, max_capacity: 3)
        create(:cm_inventory_unit, variant: variant1, inventory_date: tomorrow, quantity_available: 2, max_capacity: 3)
        create(:cm_inventory_unit, variant: variant2, inventory_date: today, quantity_available: 1, max_capacity: 3)
        create(:cm_inventory_unit, variant: variant2, inventory_date: tomorrow, quantity_available: 0, max_capacity: 3)
      end

      it 'returns only variants with sufficient availability' do
        results = service.with_available_inventory(today, tomorrow + 1, 1)
        expect(results.length).to eq(1)
        expect(results.first.variant_id).to eq(variant1.id)
      end

      it 'returns empty array when no variants meet requirements' do
        results = service.with_available_inventory(today, tomorrow + 1, 3)
        expect(results).to be_empty
      end
    end
  end

  describe '#valid_dates?' do
    it 'returns true for valid future dates' do
      expect(service.send(:valid_dates?, Date.today, Date.tomorrow)).to be true
    end

    it 'returns false for past check-in' do
      expect(service.send(:valid_dates?, Date.yesterday, Date.tomorrow)).to be false
    end

    it 'returns false when check-out is before check-in' do
      expect(service.send(:valid_dates?, Date.tomorrow, Date.today)).to be false
    end

    it 'returns false for blank dates' do
      expect(service.send(:valid_dates?, nil, Date.tomorrow)).to be false
      expect(service.send(:valid_dates?, Date.today, nil)).to be false
    end
  end

  describe '#available_inventory' do
    let(:variant) { create(:variant) }
    let(:inventories) do
      [
        build(:cm_inventory_unit, variant: variant, quantity_available: 2, max_capacity: 3),
        build(:cm_inventory_unit, variant: variant, quantity_available: 1, max_capacity: 3)
      ]
    end

    it 'returns minimum available inventory when conditions met' do
      result = service.send(:available_inventory, variant.id, inventories, 2, 1)
      expect(result.quantity_available).to eq(1)
    end

    it 'returns nil when capacity is insufficient' do
      result = service.send(:available_inventory, variant.id, inventories, 2, 4)
      expect(result).to be_nil
    end

    it 'returns nil when day count doesn’t match' do
      result = service.send(:available_inventory, variant.id, inventories, 3, 1)
      expect(result).to be_nil
    end
  end
end
