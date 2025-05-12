require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Accommodations::Find do
  describe '#initialize' do
    let(:state_id) { 1 }
    let(:from_date) { Time.zone.today }
    let(:to_date) { Time.zone.today + 2 }

    subject do
      described_class.new(
        state_id: state_id,
        from_date: from_date,
        to_date: to_date,
        number_of_adults: 2,
        number_of_kids: 1
      )
    end

    it 'initializes with correct attributes' do
      expect(subject.state_id).to eq(state_id)
      expect(subject.from_date).to eq(from_date)
      expect(subject.to_date).to eq(to_date)
      expect(subject.number_of_guests).to eq(3)
    end

    it 'calculates number_of_guests as sum of adults and kids' do
      expect(subject.number_of_guests).to eq(2 + 1)
    end
  end

  describe '#execute' do
    let(:state) { create(:state, id: 1) }
    let(:vendor) do
      create(:cm_vendor,
        default_state: state,
        primary_product_type: :accommodation,
        state: :active
      )
    end
    let(:variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: 2, vendor: vendor) } # Capacity: 4 (in option_values)
    let(:from_date) { Time.zone.today }
    let(:to_date) { Time.zone.today + 2 }

    subject do
      described_class.new(
        state_id: state.id,
        from_date: from_date,
        to_date: to_date,
        number_of_adults: 2,
        number_of_kids: 1 # Total guests: 3
      )
    end

    context 'with active vendor, accommodation type, and sufficient capacity' do
      before do
        (from_date..to_date).each do |date|
          create(:cm_inventory_item,
            variant: variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'returns vendors with available inventory and enough capacity' do
        result = subject.execute
        expect(result).to include(vendor)
      end

      it 'returns distinct vendors' do
        result = subject.execute
        expect(result.distinct).to eq(result)
      end
    end

    context 'with insufficient capacity in public_metadata' do
      let(:small_variant) { create(:cm_variant, number_of_adults: 1, number_of_kids: 1, vendor: vendor) } # Capacity: 2 (in option_values)

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: small_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return vendors with variants of insufficient capacity' do
        result = subject.execute
        expect(result).not_to include(vendor)
      end
    end

    context 'with missing number-of-adults in public_metadata' do
      let(:no_adults_variant) { create(:cm_variant, number_of_adults: nil, number_of_kids: 2, vendor: vendor) } # Capacity: 2 (in option_values)

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: no_adults_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return vendors when variant number-of-adults is missing' do
        result = subject.execute
        expect(result).not_to include(vendor)
      end
    end

    context 'with missing number-of-kids in public_metadata' do
      let(:no_kids_variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: nil, vendor: vendor) } # Capacity: 2 (in option_values)

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: no_kids_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return vendors when variant number-of-kids is missing' do
        result = subject.execute
        expect(result).not_to include(vendor)
      end
    end

    context 'with missing cm_options in public_metadata' do
      let(:no_options_variant) { create(:cm_variant, number_of_adults: nil, number_of_kids: nil, vendor: vendor) } # Capacity: 0 (in option_values)

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: no_options_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return vendors when cm_options is missing' do
        result = subject.execute
        expect(result).not_to include(vendor)
      end
    end

    context 'with null public_metadata' do
      let(:null_metadata_variant) { create(:cm_variant, number_of_adults: nil, number_of_kids: nil, vendor: vendor, public_metadata: nil) } # Capacity: 4 (in option_values)

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: null_metadata_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return vendors when public_metadata is null' do
        result = subject.execute
        expect(result).not_to include(vendor)
      end
    end

    context 'with no available inventory' do
      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: variant,
            inventory_date: date,
            quantity_available: 0
          )
        end
      end

      it 'does not return vendors with no available inventory' do
        result = subject.execute
        expect(result).to be_empty
      end
    end

    context 'with different state' do
      let(:other_state) { create(:state, id: 2) }
      let(:other_vendor) do
        create(:vendor,
          default_state: other_state,
          primary_product_type: :accommodation,
          state: :active
        )
      end
      let(:other_variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: 2, vendor: other_vendor) }

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: other_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'only returns vendors for the specified state' do
        result = subject.execute
        expect(result).not_to include(other_vendor)
      end
    end

    context 'with pending vendor' do
      let(:pending_vendor) do
        create(:vendor,
          default_state: state,
          primary_product_type: :accommodation,
          state: :pending
        )
      end
      let(:pending_variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: 2, vendor: pending_vendor) }

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: pending_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return pending vendors' do
        result = subject.execute
        expect(result).not_to include(pending_vendor)
      end
    end

    context 'with non-accommodation product type' do
      let(:non_accommodation_vendor) do
        create(:vendor,
          default_state: state,
          primary_product_type: :ecommerce,
          state: :active
        )
      end
      let(:non_accommodation_variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: 2, vendor: non_accommodation_vendor) }

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: non_accommodation_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return vendors with non-accommodation product type' do
        result = subject.execute
        expect(result).not_to include(non_accommodation_vendor)
      end
    end
  end

  describe '#date_range_excluding_checkout' do
    let(:from_date) { Time.zone.today }
    let(:to_date) { Time.zone.today + 2 }

    subject do
      described_class.new(
        state_id: 1,
        from_date: from_date,
        to_date: to_date,
        number_of_adults: 2,
        number_of_kids: 1
      )
    end

    it 'returns range from from_date to day before to_date' do
      range = subject.send(:date_range_excluding_checkout)
      expect(range).to eq(from_date..(to_date - 1))
      expect(range).not_to include(to_date)
    end
  end
end
