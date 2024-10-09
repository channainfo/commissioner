require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OrganizerProfileEventQuery do
  let(:vendor) { create(:vendor) }
  let(:upcoming_taxon) { create(:taxon, vendor_id: vendor.id, from_date: 1.day.from_now, to_date: 5.days.from_now) }
  let(:previous_taxon) { create(:taxon, vendor_id: vendor.id, from_date: 10.days.ago, to_date: 1.day.ago) }
  let(:start_from_date) { Time.zone.now }

  describe '#events' do
    context 'when section is upcoming' do
      it 'returns upcoming events for the vendor' do
        upcoming_taxon
        previous_taxon

        query = SpreeCmCommissioner::OrganizerProfileEventQuery.new(
          vendor_id: vendor.id, section: 'upcoming', start_from_date: start_from_date
        )

        result = query.events

        expect(result).to include(upcoming_taxon)
        expect(result).not_to include(previous_taxon)
        expect(result.first).to eq(upcoming_taxon)
      end
    end

    context 'when section is previous' do
      it 'returns previous events for the vendor' do
        upcoming_taxon
        previous_taxon

        query = SpreeCmCommissioner::OrganizerProfileEventQuery.new(
          vendor_id: vendor.id, section: 'previous', start_from_date: start_from_date
        )

        result = query.events

        expect(result).to include(previous_taxon)
        expect(result).not_to include(upcoming_taxon)
        expect(result.first).to eq(previous_taxon)
      end
    end

    context 'when start_from_date is not provided' do
      it 'defaults to the current time' do
        query = SpreeCmCommissioner::OrganizerProfileEventQuery.new(
           vendor_id: vendor.id, section: 'upcoming'
        )

        expect(query.start_from_date.to_i).to eq(Time.zone.now.to_i)
      end
    end
  end
end
