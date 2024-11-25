require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrganizerProfileEventQuery do
  let(:vendor) { create(:vendor) }
  let(:start_from_date) { Time.zone.now }
  let!(:upcoming_taxon) { create(:taxon, vendor_id: vendor.id, from_date: 1.day.from_now, to_date: 5.days.from_now) }
  let!(:previous_taxon) { create(:taxon, vendor_id: vendor.id, from_date: 10.days.ago, to_date: 1.day.ago) }

  describe '#events' do
    context 'when section is upcoming' do
      it 'returns only upcoming events for the vendor' do
        query = described_class.new(vendor_id: vendor.id, section: 'upcoming', start_from_date: start_from_date)
        expect(query.events).to contain_exactly(upcoming_taxon)
      end
    end

    context 'when section is previous' do
      it 'returns only previous events for the vendor' do
        query = described_class.new(vendor_id: vendor.id, section: 'previous', start_from_date: start_from_date)

        expect(query.events).to contain_exactly(previous_taxon)
      end
    end

    context 'when start_from_date is not provided' do
      it 'defaults to the current time' do
        travel_to(Time.zone.now) do
          query = described_class.new(vendor_id: vendor.id, section: 'upcoming')

          expect(query.start_from_date.to_i).to be_within(1).of(Time.zone.now.to_i)
        end
      end
    end

    context 'when section is all' do
      it 'returns all events for the vendor, both upcoming and previous' do
        query = described_class.new(vendor_id: vendor.id, section: 'all', start_from_date: start_from_date)

        expect(query.events).to match_array([upcoming_taxon, previous_taxon])
      end
    end
  end
end
