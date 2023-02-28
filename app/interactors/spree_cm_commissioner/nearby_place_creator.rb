module SpreeCmCommissioner
  class NearbyPlaceCreator < BaseInteractor
    delegate :vendor, :params, to: :context

    def call
      params.each_with_index do |param, index|
        place = SpreeCmCommissioner::Place.find_or_initialize_by(reference: param[:reference])
        place.update(param)
        NearbyPlaceDistanceFinder.call(vendor: vendor, place: place, index: index)
      end
    end
  end
end
