require 'spec_helper'

RSpec.describe SpreeCmCommissioner::GenerateGuestsCsvJob, type: :job do
  describe "#perform" do
    let(:guests) { create_list(:guest, 10) }
    let(:csv_file_path) { Rails.root.join('tmp', 'guests-data-event-name-1234567890.csv') }
    let(:guest_ids) { guests.map(&:id) }

    before do
      described_class.new.perform(guest_ids, csv_file_path)
    end

    it "creates a CSV file with the correct headers" do
      csv = CSV.read(csv_file_path)
      expect(csv.first).to eq(['Full Name', 'Date of Birth', 'Gender', 'Occupation', 'ID Card Type', 'Entry Type'])
    end

    it "creates a CSV file with a row for each guest" do
      csv = CSV.read(csv_file_path)
      expect(csv.size).to eq(guests.size + 1) # +1 for the header row
    end

    it "creates a CSV file with the correct data for each guest" do
      csv = CSV.read(csv_file_path)
      guests.each_with_index do |guest, index|
        expect(csv[index + 1][0]).to eq(guest.full_name)
      end
    end
  end
end
