module SpreeCmCommissioner
  class NearbyPlaceCreator < BaseInteractor
    delegate :vendor, :params, to: :context

    def call
      params.each_with_index do |param, index|
        place = SpreeCmCommissioner::Place.find_or_initialize_by(reference: param[:reference])
        place.update(param)

        distance = distance([vendor.lat, vendor.lon], [place.lat, place.lon])
        nearby_place = SpreeCmCommissioner::VendorPlace.find_or_initialize_by(vendor: vendor, place: place)
        nearby_place.update(distance: distance, position: index + 1)
      end
    end

    protected

    def distance(loc1, loc2)
      rad_per_deg = Math::PI / 180  # PI / 180
      rkm = 6371 # Earth radius in kilometers

      dlat_rad = (loc2[0] - loc1[0]) * rad_per_deg # Delta, converted to rad
      dlon_rad = (loc2[1] - loc1[1]) * rad_per_deg

      lat1_rad = loc1.map { |i| i * rad_per_deg }.first
      lat2_rad = loc2.map { |i| i * rad_per_deg }.first

      a = (Math.sin(dlat_rad / 2)**2) + (Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad / 2)**2))
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      (rkm * c).round(3) # Delta in kilometers
    end
  end
end
