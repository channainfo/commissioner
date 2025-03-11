require 'rails_helper'

RSpec.describe SpreeCmCommissioner::InventoryServices::BaseService, type: :service do
  describe '#initialize' do
    let(:variant_id) { 123 }
    subject { described_class.new(variant_id) }

    it 'initializes with a variant_id' do
      expect(subject.instance_variable_get(:@variant_id)).to eq(variant_id)
    end

    it 'initializes with an InventoryQuery' do
      expect(subject.instance_variable_get(:@inventory_query)).to be_an_instance_of(InventoryQuery)
    end
  end

  describe '#fetch_available_inventory' do
    let(:variant_id) { 123 }
    let(:service_type) { 'some_service' }
    let(:start_date) { Date.today }
    let(:end_date) { Date.today + 1 }
    let(:base_service) { described_class.new(variant_id) }
    let(:inventory_query) { instance_double(InventoryQuery) }

    before do
      allow(InventoryQuery).to receive(:new).and_return(inventory_query)
    end

    it 'calls fetch_available_inventory on InventoryQuery with correct parameters' do
      allow(inventory_query).to receive(:fetch_available_inventory).and_return([])

      base_service.fetch_available_inventory(service_type, start_date, end_date)

      expect(inventory_query).to have_received(:fetch_available_inventory).with(variant_id, start_date, end_date, service_type)
    end

    it 'returns the result of InventoryQuery#fetch_available_inventory' do
      expected_result = ['item1', 'item2']
      allow(inventory_query).to receive(:fetch_available_inventory).and_return(expected_result)

      result = base_service.fetch_available_inventory(service_type, start_date, end_date)

      expect(result).to eq(expected_result)
    end
  end
end
