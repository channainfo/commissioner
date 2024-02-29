require 'spec_helper'

RSpec.describe SpreeCmCommissioner::DashboardCrewEventQuery do

  let!(:start_from_date) { Time.zone.today }
  let!(:incoming_event_a) { create(:cm_taxon_event, name: 'Run with Sai', from_date: start_from_date, to_date: 2.day.from_now) }
  let!(:incoming_event_b) { create(:cm_taxon_event, name: 'BunPhum', from_date: 8.day.from_now, to_date: 11.day.from_now) }
  let!(:incoming_event_c) { create(:cm_taxon_event, name: 'TedX', from_date: 15.day.from_now, to_date: 18.day.from_now) }
  let!(:previous_event_a) { create(:cm_taxon_event, name: 'GardenSplash', from_date: start_from_date - 1.day, to_date: start_from_date - 3.day) }
  let!(:previous_event_b) { create(:cm_taxon_event, name: 'SangkranSR', from_date: 8.day.ago, to_date: 11.day.ago) }

  describe '#events' do
    let(:user_a) { create(:cm_operator_user, events: [incoming_event_a, incoming_event_b, previous_event_a, previous_event_b]) }
    let(:user_b) { create(:cm_operator_user, events: [incoming_event_a, incoming_event_b, previous_event_a, previous_event_b]) }

    it 'should return only incoming events that user has access to' do
      query_a = SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user_a.id, section: 'incoming')
      expect(query_a.events.pluck(:taxon_id)).to eq([incoming_event_a.id, incoming_event_b.id])
    end

    it 'should return only previous events that user has access to' do
      query_b = SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user_a.id, section: 'previous')
      expect(query_b.events.pluck(:taxon_id)).to eq([previous_event_a.id, previous_event_b.id])
    end

    context 'when section is incoming' do
      let(:user) { create(:cm_operator_user, events: [incoming_event_a, incoming_event_b, incoming_event_c, previous_event_a, previous_event_b]) }

      subject { SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user.id, section: 'incoming', start_from_date: start_from_date) }

      it 'should return events with from_date >= current order by from_date asc' do
        expect(incoming_event_a.from_date).to be >= start_from_date
        expect(incoming_event_b.from_date).to be >= start_from_date
        expect(incoming_event_c.from_date).to be >= start_from_date
        expect(subject.events.pluck(:taxon_id)).to eq([incoming_event_a.id, incoming_event_b.id, incoming_event_c.id])
      end
    end

    context 'when section is previous' do
      let(:user) { create(:cm_operator_user, events: [incoming_event_a, incoming_event_b, incoming_event_c, previous_event_a, previous_event_b]) }

      subject { SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user.id, section: 'previous', start_from_date: start_from_date) }

      it 'should return events with from_date < start_from_date order by to_date desc' do
        expect(previous_event_a.from_date).to be < start_from_date
        expect(previous_event_b.from_date).to be < start_from_date

        expect(subject.events.pluck(:taxon_id)).to eq([previous_event_a.id, previous_event_b.id])
      end
    end
  end
end
