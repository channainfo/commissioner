require 'spec_helper'

describe SpreeCmCommissioner::AccommodationSearch do
  describe 'validations' do
    let(:valid_params) { { from_date: Date.today, to_date: Date.today + 1.day, num_guests: 1 } }

    context 'when date range is invalid' do
      it 'adds error when to_date is before from_date' do
        search = described_class.new(from_date: Date.today, to_date: Date.yesterday)
        search.validate
        expect(search.errors[:date_range]).to include('To Date cannot be less than From Date')
      end

      it 'adds error when duration exceeds MAX_QUERY_DAYS' do
        search = described_class.new(from_date: Date.today, to_date: Date.today + 32.days)
        search.validate
        expect(search.errors[:date_range]).to include("Duration must not be greater than #{described_class::MAX_QUERY_DAYS} days")
      end
    end

    context 'when date range is valid' do
      it 'has no validation errors' do
        search = described_class.new(**valid_params)
        search.validate
        expect(search.errors).to be_empty
      end
    end
  end

  describe '#with_available_inventory' do
    let(:vendor) { create(:vendor, primary_product_type: :accommodation, state: :active) }
    let(:variant) { create(:variant, vendor: vendor) }
    let(:inventory_unit) { OpenStruct.new(variant_id: variant.id, quantity_available: 10, max_capacity: 20) }
    let(:search) { described_class.new(from_date: Date.today, to_date: Date.today + 1.day) }

    before do
      allow_any_instance_of(SpreeCmCommissioner::InventoryServices::AccommodationService)
        .to receive(:with_available_inventory).and_return([inventory_unit])
    end

    it 'constructs the correct SQL query with available inventory' do
      scope = search.with_available_inventory
      expect(scope).to be_a(ActiveRecord::Relation)
      expect(scope.klass).to eq(Spree::Vendor)
    end

    it 'applies filters correctly' do
      scope = search.with_available_inventory
      expect(scope.where_values_hash).to include(
        "primary_product_type" => :accommodation,
        "deleted_at" => nil,
        "state" => :active
      )
    end

    context 'has inventory_unit' do
      it 'returns vendors from inventory_units results' do
        expect(search.with_available_inventory).to eq([vendor])
      end
    end

    context 'no inventory_unit' do
      it 'returns vendors from inventory_units results' do
        allow_any_instance_of(SpreeCmCommissioner::InventoryServices::AccommodationService)
          .to receive(:with_available_inventory).and_return([])

        expect(search.with_available_inventory).to eq([])
      end
    end
  end

  describe '#day_count' do
    it 'calculates correct number of days excluding to_date' do
      search = described_class.new(from_date: Date.parse('2025-03-01'), to_date: Date.parse('2025-03-04'))
      expect(search.send(:day_count)).to eq(3)
    end
  end

  describe '#apply_filter' do
    let(:search) { described_class.new(from_date: Date.today, to_date: Date.today + 1.day, province_id: 1, vendor_id: 2) }
    let(:scope) { Spree::Vendor.all }

    it 'applies all filters when present' do
      filtered_scope = search.send(:apply_filter, scope)

      expect(filtered_scope.where_values_hash).to include(
        "primary_product_type" => :accommodation,
        "deleted_at" => nil,
        "state" => :active,
        "default_state_id" => 1,
        "id" => 2
      )
    end
  end
end
