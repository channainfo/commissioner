require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AccommodationInventory do
  let(:today) { Date.today }
  let(:variant1) { create(:variant, product: create(:product, product_type: 'accommodation')) }
  let(:variant2) { create(:variant, product: create(:product, product_type: 'accommodation')) }
  let(:variant_ids) { [variant1.id, variant2.id] }
  let(:check_in) { today + 1 }
  let(:check_out) { today + 3 }
  let(:num_guests) { 2 }

  subject { described_class.new(variant_ids: variant_ids, check_in: check_in, check_out: check_out, num_guests: num_guests) }

  describe '#initialize' do
    it 'sets attributes correctly' do
      expect(subject.variant_ids).to eq(variant_ids)
      expect(subject.check_in).to eq(check_in)
      expect(subject.check_out).to eq(check_out)
      expect(subject.num_guests).to eq(num_guests)
    end

    it 'defaults variant_ids to empty array when nil' do
      instance = described_class.new(variant_ids: nil, check_in: check_in, check_out: check_out, num_guests: num_guests)
      expect(instance.variant_ids).to eq([])
    end

    it 'defaults num_guests to 0 when nil' do
      instance = described_class.new(variant_ids: variant_ids, check_in: check_in, check_out: check_out, num_guests: nil)
      expect(instance.num_guests).to eq(0)
    end
  end

  describe '#fetch_inventory' do
    context 'when dates are invalid' do
      let(:check_in) { today - 1 } # Past date

      it 'returns an empty array' do
        expect(subject.fetch_inventory).to eq([])
      end
    end

    context 'when dates are valid' do
      let(:inventory_item) { double(variant_id: 1, quantity_available: 5, max_capacity: 3) }
      let(:inventory_items) { [inventory_item] }

      before do
        allow(subject).to receive(:inventory_items).and_return(inventory_items)
      end

      it 'returns unique variant inventories' do
        expect(subject).to receive(:select_min_inventory).with(1).and_return(inventory_item)
        expect(subject.fetch_inventory).to eq([inventory_item])
      end

      it 'filters out nil results' do
        allow(subject).to receive(:select_min_inventory).with(1).and_return(nil)
        expect(subject.fetch_inventory).to eq([])
      end
    end

    context 'scenario 1: 1 guest, 1 room, 2 nights' do
      let(:check_in) { today }
      let(:check_out) { today + 2 }
      let!(:inventory_today) { create(:cm_inventory_item, variant: variant1, inventory_date: today, quantity_available: 2, max_capacity: 3) }
      let!(:inventory_tomorrow) { create(:cm_inventory_item, variant: variant1, inventory_date: today + 1, quantity_available: 1, max_capacity: 3) }

      it 'returns available inventory' do
        result = subject.fetch_inventory
        expect(result.length).to eq(1)
        expect(result.first.variant_id).to eq(variant1.id)
        expect(result.first.quantity_available).to eq(1) # Minimum available across days
      end
    end

    context 'scenario 2: 2 guests, 2 rooms, 2 nights with insufficient availability' do
      let(:check_in) { today }
      let(:check_out) { today + 2 }
      let!(:inventory_today) { create(:cm_inventory_item, variant: variant1, inventory_date: today, quantity_available: 2, max_capacity: 2) }
      let!(:inventory_tomorrow) { create(:cm_inventory_item, variant: variant1, inventory_date: today + 1, quantity_available: 1, max_capacity: 3) }

      it 'returns inventory event quantity(room) is insufficient' do
        result = subject.fetch_inventory
        expect(result.length).to eq(1)
        expect(result.first.variant_id).to eq(variant1.id)
      end
    end
  end

  describe '#inventory_items' do
    let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION }

    it 'calls fetch_inventory_items with correct parameters' do
      expect(subject).to receive(:fetch_inventory_items)
        .with(variant_ids, check_in, check_out, product_type)
        .and_return([])
      subject.send(:inventory_items)
    end

    it 'memoizes the result' do
      expect(subject).to receive(:fetch_inventory_items).once.and_return([])
      2.times { subject.send(:inventory_items) }
    end
  end

  describe '#day_count' do
    it 'calculates correct number of days' do
      expect(subject.send(:day_count)).to eq(2) # today+1 to today+2 (2 days)
    end

    it 'memoizes the result' do
      result = subject.send(:day_count)
      expect(subject.instance_variable_get(:@day_count)).to eq(result)
    end
  end

  describe '#select_min_inventory' do
    let(:variant_id) { 1 }
    let(:inventory_items) do
      [
        double(variant_id: 1, max_capacity: 3, quantity_available: 5),
        double(variant_id: 1, max_capacity: 3, quantity_available: 2)
      ]
    end

    before do
      allow(subject).to receive(:inventory_items).and_return(inventory_items)
    end

    context 'when conditions are not met' do
      it 'returns nil if not enough days covered' do
        allow(subject).to receive(:day_count).and_return(3)
        expect(subject.send(:select_min_inventory, variant_id)).to be_nil
      end

      it 'returns nil if max_capacity is less than num_guests' do
        inventory_items[0] = double(variant_id: 1, max_capacity: 1, quantity_available: 5)
        expect(subject.send(:select_min_inventory, variant_id)).to be_nil
      end

      it 'returns nil if quantity_available is 0' do
        inventory_items[0] = double(variant_id: 1, max_capacity: 3, quantity_available: 0)
        expect(subject.send(:select_min_inventory, variant_id)).to be_nil
      end
    end

    context 'when conditions are met' do
      it 'returns the inventory with minimum quantity_available' do
        expect(subject.send(:select_min_inventory, variant_id)).to eq(inventory_items[1])
      end
    end
  end

  describe '#valid_dates?' do
    context 'with blank dates' do
      it 'returns false when check_in is nil' do
        subject.instance_variable_set(:@check_in, nil)
        subject.instance_variable_set(:@check_out, today + 1)
        expect(subject.send(:valid_dates?)).to be false
      end

      it 'returns false when check_out is nil' do
        subject.instance_variable_set(:@check_in, today + 1)
        subject.instance_variable_set(:@check_out, nil)
        expect(subject.send(:valid_dates?)).to be false
      end
    end

    context 'with non-Date objects' do
      it 'returns false when check_in is not a Date' do
        subject.instance_variable_set(:@check_in, '2025-04-01')
        subject.instance_variable_set(:@check_out, today + 1)
        expect(subject.send(:valid_dates?)).to be false
      end

      it 'returns false when check_out is not a Date' do
        subject.instance_variable_set(:@check_in, today + 1)
        subject.instance_variable_set(:@check_out, '2025-04-02')
        expect(subject.send(:valid_dates?)).to be false
      end
    end

    context 'with invalid date order' do
      it 'returns false when check_out is before check_in' do
        subject.instance_variable_set(:@check_in, today + 2)
        subject.instance_variable_set(:@check_out, today + 1)
        expect(subject.send(:valid_dates?)).to be false
      end

      it 'returns false when check_out equals check_in' do
        subject.instance_variable_set(:@check_in, today + 1)
        subject.instance_variable_set(:@check_out, today + 1)
        expect(subject.send(:valid_dates?)).to be false
      end
    end

    context 'with past dates' do
      it 'returns false when check_in is before today' do
        subject.instance_variable_set(:@check_in, today - 1)
        subject.instance_variable_set(:@check_out, today + 1)
        expect(subject.send(:valid_dates?)).to be false
      end
    end

    context 'with valid dates' do
      it 'returns true for future dates' do
        subject.instance_variable_set(:@check_in, today + 1)
        subject.instance_variable_set(:@check_out, today + 2)
        expect(subject.send(:valid_dates?)).to be true
      end

      it 'returns true for today as check_in' do
        subject.instance_variable_set(:@check_in, today)
        subject.instance_variable_set(:@check_out, today + 1)
        expect(subject.send(:valid_dates?)).to be true
      end
    end
  end

  describe '#product_type' do
    it 'returns the accommodation product type' do
      expect(subject.send(:product_type)).to eq(SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION)
    end
  end
end
