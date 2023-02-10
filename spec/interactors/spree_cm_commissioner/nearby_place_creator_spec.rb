require 'spec_helper'

RSpec.describe SpreeCmCommissioner::NearbyPlaceCreator do
  let(:state) { create(:state, name: 'Siemreap') }
  let!(:place) { create(:cm_place, lat: 11.2181123, lon: 11.3181223) }
  let!(:vendor) { create(:active_vendor, name: 'Angkor Hotel') }
  let!(:stock_location) { vendor.stock_locations.first.update(state: state, lat: 10.2181123, lon: 10.3181223) }
  let(:params) {
    [
      {
        "lat": 10.6184423,
        "lon": 104.1694313,
        "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/bar-71.png",
        "name": "Cruise Bar",
        "reference": "ChIJi6C1MxquEmsR9-c-3O48ykI",
        "rating": 4.8,
        "types":
          ["bar", "restaurant", "food", "point_of_interest", "establishment"],
        "vicinity": "Level 1, 2 and 3, Overseas Passenger Terminal, Circular Quay W, The Rocks",
      },
      {
        "lat": 10.6136337,
        "lon": 104.1704398,
        "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
        "name": "Sydney Harbour Dinner Cruises",
        "reference": "ChIJM1mOVTS6EmsRKaDzrTsgids",
        "rating": 4.5,
        "types":
          [
            "tourist_attraction",
            "travel_agency",
            "restaurant",
            "food",
            "point_of_interest",
            "establishment",
          ],
        "vicinity": "32 The Promenade, Sydney",
      }
    ]
  }

  describe '.call' do
    before :each do
      described_class.call(params: params , vendor: vendor)
    end

    it 'should create 2 nearby places for vendor' do
      expect(vendor.nearby_places.count).to eq 2
    end

    it 'should create 2 places from google params for vendor' do
      expect(vendor.places.count).to eq 2
    end

    it 'should return 3 places from database' do
      expect(SpreeCmCommissioner::Place.count).to eq 3
    end

    it 'save with distance' do
      expect(vendor.nearby_places[0].distance).not_to be_nil
      expect(vendor.nearby_places[1].distance).not_to be_nil
    end
  end
end
