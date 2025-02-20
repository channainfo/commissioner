require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrganizerProfileEventQuery do
  let(:vendor) { create(:vendor) }
  let(:slug) { vendor.slug }
  let(:start_from_date) { Time.zone.now }
  let!(:upcoming_taxon) { create(:taxon, vendor: vendor, from_date: 1.day.from_now, to_date: 5.days.from_now) }
  let!(:previous_taxon) { create(:taxon, vendor: vendor, from_date: 10.days.ago, to_date: 1.day.ago) }

  describe '#events' do
    context 'when section is upcoming' do
      it 'returns only upcoming events for the vendor by vendor_id' do
        query = described_class.new(vendor_identifier: vendor.id, section: 'upcoming', start_from_date: start_from_date)
        events = query.events
        expect(events).to contain_exactly(upcoming_taxon)
      end

      it 'returns only upcoming events for the vendor by slug' do
        query = described_class.new(vendor_identifier: slug, section: 'upcoming', start_from_date: start_from_date)
        events = query.events
        expect(events).to contain_exactly(upcoming_taxon)
      end
    end

    context 'when section is previous' do
      it 'returns only previous events for the vendor by vendor_id' do
        query = described_class.new(vendor_identifier: vendor.id, section: 'previous', start_from_date: start_from_date)
        events = query.events
        expect(events).to contain_exactly(previous_taxon)
      end

      it 'returns only previous events for the vendor by slug' do
        query = described_class.new(vendor_identifier: slug, section: 'previous', start_from_date: start_from_date)
        events = query.events
        expect(events).to contain_exactly(previous_taxon)
      end
    end

    context 'when section is all' do
      it 'returns all events for the vendor, both upcoming and previous' do
        query = described_class.new(vendor_identifier: vendor.id, section: 'all', start_from_date: start_from_date)
        events = query.events
        expect(events).to match_array([upcoming_taxon, previous_taxon])
      end

      it 'returns all events for the vendor by slug, both upcoming and previous' do
        query = described_class.new(vendor_identifier: slug, section: 'all', start_from_date: start_from_date)
        events = query.events
        expect(events).to match_array([upcoming_taxon, previous_taxon])
      end
    end
  end
end
