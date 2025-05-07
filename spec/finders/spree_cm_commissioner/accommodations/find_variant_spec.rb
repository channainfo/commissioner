require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Accommodations::FindVariant do
  describe '#initialize' do
    let(:vendor_id) { 1 }
    let(:from_date) { Time.zone.today }
    let(:to_date) { Time.zone.today + 2 }

    subject do
      described_class.new(
        vendor_id: vendor_id,
        from_date: from_date,
        to_date: to_date,
        number_of_adults: 2,
        number_of_kids: 1
      )
    end

    it 'initializes with correct attributes' do
      expect(subject.vendor_id).to eq(vendor_id)
      expect(subject.from_date).to eq(from_date)
      expect(subject.to_date).to eq(to_date)
      expect(subject.number_of_guests).to eq(3)
    end

    it 'calculates number_of_guests as sum of adults and kids' do
      expect(subject.number_of_guests).to eq(2 + 1)
    end
  end

  describe '#execute' do
    let(:vendor) { create(:vendor) }
    let(:variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: 2, vendor: vendor) } # Capacity: 4
    let(:from_date) { Time.zone.today }
    let(:to_date) { Time.zone.today + 2 }

    subject do
      described_class.new(
        vendor_id: vendor.id,
        from_date: from_date,
        to_date: to_date,
        number_of_adults: 2,
        number_of_kids: 1 # Total guests: 3
      )
    end

    context 'with available inventory and sufficient capacity' do
      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'returns variants with available inventory and enough capacity' do
        result = subject.execute
        expect(result).to include(variant)
      end

      it 'returns distinct variants' do
        result = subject.execute
        expect(result.distinct).to eq(result)
      end
    end

    context 'with insufficient capacity' do
      let(:small_variant) { create(:cm_variant, number_of_adults: 1, number_of_kids: 1, vendor: vendor) } # Capacity: 2

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: small_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return variants with insufficient capacity' do
        result = subject.execute
        expect(result).not_to include(small_variant)
      end
    end

    context 'with only number_of_adults' do
      let(:adults_only_variant) { create(:cm_variant, number_of_adults: 2, number_of_kids: nil, vendor: vendor) } # Capacity: 2

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: adults_only_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return variants with insufficient capacity when number_of_kids is missing' do
        result = subject.execute
        expect(result).not_to include(adults_only_variant)
      end
    end

    context 'with only number_of_kids' do
      let(:kids_only_variant) { create(:cm_variant, number_of_adults: nil, number_of_kids: 2, vendor: vendor) } # Capacity: 2

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: kids_only_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return variants with insufficient capacity when number_of_adults is missing' do
        result = subject.execute
        expect(result).not_to include(kids_only_variant)
      end
    end

    context 'with no option values' do
      let(:no_options_variant) { create(:cm_variant, number_of_adults: nil, number_of_kids: nil, vendor: vendor) } # Capacity: 0

      before do
        (from_date..to_date.prev_day).each do |date|
          create(:cm_inventory_item,
            variant: no_options_variant,
            inventory_date: date,
            quantity_available: 5
          )
        end
      end

      it 'does not return variants with no capacity' do
        result = subject.execute
        expect(result).not_to include(no_options_variant)
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

      it 'does not return variants with no available quantity' do
        result = subject.execute
        expect(result).to be_empty
      end
    end

    context 'with different vendor' do
      let(:other_vendor) { create(:vendor) }
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

      it 'only returns variants for the specified vendor' do
        result = subject.execute
        expect(result).not_to include(other_variant)
      end
    end
  end

  describe '#date_range_excluding_checkout' do
    let(:from_date) { Time.zone.today }
    let(:to_date) { Time.zone.today + 2 }

    subject do
      described_class.new(
        vendor_id: 1,
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
