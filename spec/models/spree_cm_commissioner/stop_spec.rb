require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stop, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:branch).class_name('SpreeCmCommissioner::Branch') }
    it { is_expected.to belong_to(:state).class_name('Spree::State').optional }
    it { is_expected.to belong_to(:vendor).class_name('Spree::Vendor') }
  end

  describe '#validate_reference?' do
    it 'returns false' do
      stop = described_class.new
      expect(stop.validate_reference?).to eq(false)
    end
  end

  describe 'callbacks' do
    describe 'after_save :add_to_option_value' do
      let!(:origin_option_type) { create(:option_type, attr_type: 'origin') }
      let!(:destination_option_type) { create(:option_type, attr_type: 'destination') }
      let(:stop) { build(:cm_stop, name: 'Test Stop') }

      it 'creates option values for origin and destination' do
        expect {
          stop.save
        }.to change { Spree::OptionValue.count }.by(2)

        origin_option_value = Spree::OptionValue.find_by(option_type: origin_option_type)
        destination_option_value = Spree::OptionValue.find_by(option_type: destination_option_type)

        expect(origin_option_value).to have_attributes(name: 'Test Stop', presentation: stop.id.to_s)
        expect(destination_option_value).to have_attributes(name: 'Test Stop', presentation: stop.id.to_s)
      end
    end
  end
end
