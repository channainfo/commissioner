require 'spec_helper'
require 'csv'

RSpec.describe SpreeCmCommissioner::GenerateGuestsCsv, '.call' do
  subject(:context) { described_class.call(collection: collection, file_name: file_name) }

  let(:guest1) { create(:guest, first_name: 'John', last_name: 'Doe', dob: Date.new(1990, 1, 1), gender: 1, occupation: create(:taxon, name: 'Engineer'), id_card: create(:id_card, card_type: 0), entry_type: 1) }
  let(:guest2) { create(:guest, first_name: 'Jane', last_name: 'Smith', dob: Date.new(1985, 5, 5), gender: 2, occupation: create(:taxon, name: 'Doctor'), id_card: create(:id_card, card_type: 1), entry_type: 0) }
  let(:collection) { SpreeCmCommissioner::Guest.where(id: [guest1.id, guest2.id]) }
  let(:file_name) { Rails.root.join('tmp', 'csv_file.csv') }
  let(:csv_file) { CSV.read(Rails.root.join(file_name)) }

  describe ".call" do
    it 'creates the CSV file with correct path and filename and data' do
      expect(context).to be_a_success
      expect(context.file_name).to eq(file_name)

      expect(csv_file.first).to eq(['Full Name', 'Date of Birth', 'Gender', 'Occupation', 'ID Card Type', 'Entry Type'])
      expect(csv_file[1]).to eq([guest1.full_name, '01 Jan 1990', 'Male', 'Engineer', 'National Id Card', 'Vip'])
      expect(csv_file[2]).to eq([guest2.full_name, '05 May 1985', 'Female', 'Doctor', 'Passport', 'Normal'])
    end
  end
end
