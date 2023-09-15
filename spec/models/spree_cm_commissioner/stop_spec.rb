require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stop, type: :model do
  describe '#add_to_option_value' do
    let!(:vendor) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', code: 'PPH') }

    it 'auto create optoin_value after save ' do
      location = create(:state)
      branch = create(:cm_branch, state: location, vendor: vendor)
      destination = Spree::OptionType.create(name: 'destination', presentation: 'destination',attr_type: 'destination')
      origin = Spree::OptionType.create(name: 'origin', presentation: 'origin',attr_type: 'origin')

      expect(Spree::OptionValue.where(option_type_id: destination.id).count).to eq 0
      expect(Spree::OptionValue.where(option_type_id: origin.id).count).to eq 0

      stop = described_class.create(name: 'testStop', branch_id: branch.id, state_id: location.id, vendor_id: vendor.id,code: 'TS',lat: 11.11, lon: 11.11, formatted_address: 'test_address', formatted_phone_number: 12345678)

      expect(Spree::OptionValue.where(option_type_id: destination.id).count).to eq 1
      expect(Spree::OptionValue.where(option_type_id: origin.id).count).to eq 1

      place = SpreeCmCommissioner::Place.create(name: 'testPlace', branch_id: branch.id, state_id: location.id, vendor_id: vendor.id,code: 'TP',lat: 11.11, lon: 11.11, formatted_address: 'test_address', formatted_phone_number: 12345678)

      expect(Spree::OptionValue.where(option_type_id: destination.id).count).to eq 1
      expect(Spree::OptionValue.where(option_type_id: origin.id).count).to eq 1
    end
  end
end