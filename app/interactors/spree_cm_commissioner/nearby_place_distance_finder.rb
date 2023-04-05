module SpreeCmCommissioner
  class NearbyPlaceDistanceFinder < BaseInteractor
    delegate :vendor, :place, to: :context

    def call
      context.distance = get_distance([vendor.lat, vendor.lon], [place.lat, place.lon])
    end

    protected

    def get_distance(loc1, loc2)
      rad_per_deg = Math::PI / 180 # PI / 180
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
