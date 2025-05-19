require 'spec_helper'

RSpec.describe SpreeCmCommissioner::DashboardCrewEventQuery do

  let!(:start_from_date) { Time.zone.today }
  let!(:incoming_event_a) { create(:cm_taxon_event, name: 'Run with Sai', from_date: start_from_date, to_date: 2.day.from_now) }
  let!(:incoming_event_b) { create(:cm_taxon_event, name: 'BunPhum', from_date: 8.day.from_now, to_date: 11.day.from_now) }
  let!(:incoming_event_c) { create(:cm_taxon_event, name: 'TedX', from_date: 15.day.from_now, to_date: 18.day.from_now) }

  let!(:previous_event_a) { build(:cm_taxon_event, name: 'GardenSplash', from_date: start_from_date - 1.day, to_date: start_from_date - 3.days) }
  let!(:previous_event_b) { build(:cm_taxon_event, name: 'SangkranSR', from_date: 8.days.ago, to_date: 11.days.ago) }

  before do
    previous_event_a.save(validate: false)
    previous_event_b.save(validate: false)
  end

  describe '#events' do
    let(:user_a) do
      user = create(:cm_operator_user)
      user.events << incoming_event_a
      user.events << incoming_event_b
      user.events << previous_event_a
      user.events << previous_event_b
      user
    end
    let(:user_b) do
      user = create(:cm_operator_user)
      user.events << incoming_event_a
      user.events << incoming_event_b
      user.events << previous_event_a
      user.events << previous_event_b
      user
    end

    it 'should return only incoming events that user has access to' do
      query_a = SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user_a.id, section: 'incoming')
      expect(query_a.events.pluck(:taxon_id)).to match_array([incoming_event_a.id, incoming_event_b.id])
    end

    it 'should return only previous events that user has access to' do
      query_b = SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user_a.id, section: 'previous')
      expect(query_b.events.pluck(:taxon_id)).to match_array([previous_event_a.id, previous_event_b.id])
    end

    context 'when section is incoming' do
      let(:user) do
        user = create(:cm_operator_user)
        user.events << incoming_event_a
        user.events << incoming_event_b
        user.events << incoming_event_c
        user.events << previous_event_a
        user.events << previous_event_b
        user
      end

      subject { SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user.id, section: 'incoming', start_from_date: start_from_date) }

      it 'should return events with from_date >= current order by from_date asc' do
        expect(incoming_event_a.from_date).to be >= start_from_date
        expect(incoming_event_b.from_date).to be >= start_from_date
        expect(incoming_event_c.from_date).to be >= start_from_date
        expect(subject.events.pluck(:taxon_id)).to match_array([incoming_event_a.id, incoming_event_b.id, incoming_event_c.id])
      end

      context 'when start_from_date not yet pass to_date (can ignore from_date)' do
        let!(:start_from_date) { Time.zone.now }

        let(:incoming_event_a) { create(:cm_taxon_event, name: 'LongTedX', to_date: start_from_date + 10.second) }
        let(:incoming_event_b) { create(:cm_taxon_event, name: 'LongTedX', to_date: start_from_date + 1.days) }

        let!(:user) { create(:cm_operator_user, events: [incoming_event_a, incoming_event_b]) }

        it 'return both events' do
          query_a = SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user.id, section: 'incoming')
          expect(query_a.events.pluck(:taxon_id)).to match_array([incoming_event_a.id, incoming_event_b.id])
        end
      end
    end

    context 'when section is previous' do
      let(:user) do
        user = create(:cm_operator_user)
        user.events << incoming_event_a
        user.events << incoming_event_b
        user.events << incoming_event_c
        user.events << previous_event_a
        user.events << previous_event_b
        user
      end

      subject { SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user.id, section: 'previous', start_from_date: start_from_date) }

      it 'should return events with from_date < start_from_date order by to_date desc' do
        expect(previous_event_a.from_date).to be < start_from_date
        expect(previous_event_b.from_date).to be < start_from_date

        expect(subject.events.pluck(:taxon_id)).to match_array([previous_event_a.id, previous_event_b.id])
      end
    end

    it 'should complete within a reasonable time and not cause a loop' do
      query = SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user_a.id, section: 'incoming')
      expect {query.events}.not_to raise_error

      expect {Timeout.timeout(1) {query.events}}.not_to raise_error
    end

    it 'should not loop excessively for each item' do
      # Capture the Rails logger to inspect logs
      logs = StringIO.new
      Rails.logger = Logger.new(logs)

      # Execute the query
      query = SpreeCmCommissioner::DashboardCrewEventQuery.new(user_id: user_a.id, section: 'incoming')

      # Expectation: The query should complete without raising any errors
      expect { query.events }.not_to raise_error

      # Expectation: Check Rails logs for excessive looping
      expect(logs.string).not_to include('Loop detected')  # Adjust this log message according to your implementation

      # Restore the original Rails logger
      Rails.logger = ActiveSupport::Logger.new(STDOUT)
    end
  end
end
