require 'spec_helper'

RSpec.describe SpreeCmCommissioner::NearbyPlaceCreator do
  let(:place) { create(:cm_place) }
  let(:state) { create(:state, name: 'Siemreap') }
  let(:vendor) { create(:active_vendor, name: 'Angkor Hotel') }
  let!(:stock_location) { vendor.stock_locations.first.update(state: state) }
  let(:nearby_place) { create(:cm_vendor_place, vendor: vendor, place: place) }

  describe '.call' do

  end
end
