require 'spec_helper'

RSpec.describe SpreeCmCommissioner::BusInventory do
  let(:today) { Date.today }
  let(:variant_ids) { [1, 2, 3] }
  let(:trip_date) { today + 1 }

  subject { described_class.new(variant_ids: variant_ids, trip_date: trip_date) }

  describe '#initialize' do
    it 'sets variant_ids and trip_date correctly' do
      expect(subject.variant_ids).to eq(variant_ids)
      expect(subject.trip_date).to eq(trip_date)
    end

    it 'defaults variant_ids to empty array when not provided' do
      instance = described_class.new(trip_date: trip_date)
      expect(instance.variant_ids).to eq([])
    end

    it 'raises an error if trip_date is not provided' do
      expect { described_class.new(variant_ids: variant_ids) }.to raise_error(ArgumentError, /missing keyword: :?trip_date/)
    end
  end

  describe '#fetch_inventory' do
    let(:inventory_items) { [double(variant_id: 1), double(variant_id: 2)] }

    it 'returns the result of inventory_items' do
      expect(subject).to receive(:inventory_items).and_return(inventory_items)
      expect(subject.fetch_inventory).to eq(inventory_items)
    end
  end

  describe '#inventory_items' do
    let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS }

    it 'calls fetch_inventory_items with correct parameters' do
      expect(subject).to receive(:fetch_inventory_items)
        .with(variant_ids, trip_date, trip_date.next_day, product_type)
        .and_return([])
      subject.send(:inventory_items)
    end

    it 'memoizes the result' do
      expect(subject).to receive(:fetch_inventory_items).once.and_return([])
      2.times { subject.send(:inventory_items) }
    end

    context 'with different trip dates' do
      let(:trip_date) { Date.new(2025, 4, 1) }
      let(:next_day) { Date.new(2025, 4, 2) }

      it 'uses trip_date and next day as date range' do
        expect(subject).to receive(:fetch_inventory_items)
          .with(variant_ids, trip_date, next_day, product_type)
          .and_return([])
        subject.send(:inventory_items)
      end
    end
  end

  describe '#product_type' do
    it 'returns the bus product type' do
      expect(subject.send(:product_type)).to eq(SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS)
    end
  end
end
