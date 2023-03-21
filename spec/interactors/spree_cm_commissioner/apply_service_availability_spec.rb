require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ApplyServiceAvailability do
  let!(:vendor) { create(:vendor) }
  let(:monday)  { date('2023-01-02') }
  let(:sunday)  { monday + 6.days }
  let(:weekday_calendar) { create(:cm_service_calendar, calendarable: vendor, saturday: false, sunday: false) }

  context 'support single or collection' do
    it 'calendarable as single' do
      calendarable = described_class.call(calendarable: vendor, from_date: monday, to_date: sunday).value
      expect(calendarable.service_availabilities).to be_present
    end

    it 'calendarable as collection' do
      create(:vendor)
      calendarables = described_class.call(calendarable: Spree::Vendor.all, from_date: monday, to_date: sunday).value
      expect(calendarables[0].service_availabilities).to be_present
      expect(calendarables[1].service_availabilities).to be_present
    end
  end
end
