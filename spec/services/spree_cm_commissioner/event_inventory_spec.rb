require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EventInventory do
  let(:variant_ids) { [1, 2, 3] }

  subject { described_class.new(variant_ids: variant_ids) }

  describe '#initialize' do
    it 'sets variant_ids correctly' do
      expect(subject.variant_ids).to eq(variant_ids)
    end

    it 'defaults variant_ids to empty array when not provided' do
      instance = described_class.new
      expect(instance.variant_ids).to eq([])
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
    let(:product_type) { SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_EVENT }

    it 'calls fetch_inventory_items with correct parameters' do
      expect(subject).to receive(:fetch_inventory_items)
        .with(variant_ids, nil, nil, product_type)
        .and_return([])
      subject.send(:inventory_items)
    end

    it 'memoizes the result' do
      expect(subject).to receive(:fetch_inventory_items).once.and_return([])
      2.times { subject.send(:inventory_items) }
    end

    context 'with empty variant_ids' do
      let(:variant_ids) { [] }

      it 'still calls fetch_inventory_items with empty array' do
        expect(subject).to receive(:fetch_inventory_items)
          .with([], nil, nil, product_type)
          .and_return([])
        subject.send(:inventory_items)
      end
    end
  end

  describe '#product_type' do
    it 'returns the event product type' do
      expect(subject.send(:product_type)).to eq(SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_EVENT)
    end
  end
end
