require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ServiceCalendar, type: :model do
  describe 'associations' do
    it { should belong_to(:calendarable) }
    it { should have_many(:service_calendar_dates) }
  end

  context 'service calendar' do
    let(:monday) { date('2023-01-02') }
    it 'is open on Monday' do
      service_calendar = create(:cm_service_calendar, monday: true)
      expect(service_calendar.service_available?(monday)).to eq true
    end

    it 'is closed on Monday' do
      service_calendar = create(:cm_service_calendar, monday: false)
      expect(service_calendar.service_available?(monday)).to eq false
    end

    it 'is closed outside of date range' do
      service_calendar = create(:cm_service_calendar, start_date: date('2023-02-01'), end_date: date('2023-03-01'))

      expect(service_calendar.service_available?(date('2023-01-01'))).to eq false
      expect(service_calendar.service_available?(date('2023-04-01'))).to eq false
    end
  end

  context 'exception calendar' do
    let(:service_calendar) { create(:cm_service_calendar) }
    let(:day) { date('2023-01-02') }

    it 'inclusion' do
      create(:cm_service_calendar_date, service_calendar: service_calendar, date: day)

      expect(service_calendar.service_available?(day)).to eq true
    end

    it 'exclusion' do
      create(:cm_service_calendar_date, service_calendar: service_calendar, date: day, exception_type: :exclusion)

      expect(service_calendar.service_available?(day)).to eq false
    end
  end
end
