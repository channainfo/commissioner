require 'spec_helper'
require 'csv'

RSpec.describe SpreeCmCommissioner::Organizer::ExportGuestCsvService do
  let(:taxonomy) { create(:taxonomy, kind: :event) }

  let(:option_type) { create(:cm_option_type, name: 'Ticket Type ') }
  let(:option_value) { create(:cm_option_value, name: 'Standard', option_type: option_type) }
  let(:variant) { create(:variant, option_values: [option_value]) }
  let(:line_item) { create(:line_item, variant:variant) }
  let(:guest) { create(:guest, first_name: 'Panha', last_name: 'Chom', phone_number: '012123456', dob: '1986-03-28', line_item:line_item) }

  let(:columns) { ['guest_name', 'guest_phone_number', 'guest_dob', "#{option_type.name}"] }
  let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy , guests:[guest]) }

  subject(:service) { described_class.new(event.id, columns) }


  describe '#initialize' do
    it 'sets the event_id and columns correctly' do
      expect(service.event_id).to eq(event.id)
      expect(service.columns).to eq(columns)
    end
  end

  describe '#call' do
    let(:csv_output) { service.call }

    it 'generates a CSV with headers' do
      headers = CSV.parse(csv_output).first

      expect(headers).to eq(columns.map(&:humanize).uniq)
    end

    it 'generates a CSV with guest data' do
      row = CSV.parse(csv_output)[1]

      expect(row).to include("#{guest.first_name} #{guest.last_name}".strip)
      expect(row).to include(guest.phone_number)
      expect(row).to include(guest.dob.to_s)
    end
  end

  describe '#fetch_value' do

    it 'fetch the correct value for guest fields' do
      expect(service.send(:fetch_value, guest, 'guest_name')).to eq("#{guest.first_name} #{guest.last_name}".strip)
      expect(service.send(:fetch_value, guest, 'guest_phone_number')).to eq(guest.phone_number)
    end

    it 'fetch the correct value for option types fields' do
      option_type_field = "#{option_type.name}".strip
      option_value_fetched = service.send(:fetch_value, guest, option_type_field)

      expect(option_value_fetched).to eq('Standard')
    end
  end
end
