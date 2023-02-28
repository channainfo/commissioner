require 'spec_helper'

RSpec.describe SpreeCmCommissioner::NearbyPlacesLoader , :vcr do
  let(:stock_location_0) { create(:stock_location,  lat:10.632263962045458, lon:104.16990576842109 ) }
  let(:vendor) { create(:vendor , name: 'Villa vedici', stock_locations: [stock_location_0]) }
  let(:google_map_key) { "AIzaSyBt-OSnDZze6hxGjfiapSxpcyGzBo_COv8"}

  describe '.call' do
    before :each do
      interactor = described_class.new(vendor: vendor)
      allow(interactor). to receive(:google_map_key).and_return(google_map_key)
      interactor.call
    end

    it 'should get 20 nearby places for vendor' do
      expect(vendor.nearby_places.count).to eq 20
    end

    it 'save with distance' do
      expect(vendor.nearby_places[0].distance).not_to be_nil
      expect(vendor.nearby_places[1].distance).not_to be_nil
    end
  end
end