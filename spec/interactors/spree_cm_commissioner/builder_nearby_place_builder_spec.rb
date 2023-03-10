require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorNearbyPlaceBuilder , :vcr do
  describe '.call' do
    let(:stock_location_0) { create(:stock_location,  lat:10.632263962045458, lon:104.16990576842109 ) }
    let(:vendor) { create(:vendor , name: 'Villa vedici', stock_locations: [stock_location_0]) }
    let(:google_map_key) { "AIzaSyBt-OSnDZze6hxGjfiapSxpcyGzBo_COv8"}
    let(:subject) { described_class.new(vendor: vendor) }

    it 'should get 20 nearby places for vendor' do
      allow(subject). to receive(:google_map_key).and_return(google_map_key)
      places = subject.call
      expect(places.count).to eq 20
    end
  end
end