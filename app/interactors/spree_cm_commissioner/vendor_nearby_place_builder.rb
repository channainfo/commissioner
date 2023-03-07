module SpreeCmCommissioner
  class VendorNearbyPlaceBuilder < BaseInteractor
    delegate :vendor, to: :context

    def call
      context.nearby_places = []

      json_response = fetch_nearby_places
      json_response['results'].each_with_index do |json, _|
        place = SpreeCmCommissioner::Place.find_or_initialize_by(reference: json['reference'])

        place.assign_attributes(
          reference: json['reference'],
          types: json['types'][0],
          name: json['name'],
          vicinity: json['vicinity'],
          lat: json['geometry']['location']['lat'],
          lon: json['geometry']['location']['lng'],
          icon: json['icon'],
          rating: json['rating']
        )

        distance = SpreeCmCommissioner::NearbyPlaceDistanceFinder.call(
          vendor: vendor,
          place: place
        ).distance

        nearby_place = if place.persisted?
                         SpreeCmCommissioner::VendorPlace.find_or_initialize_by(vendor_id: vendor.id, place_id: place.id)
                       else
                         SpreeCmCommissioner::VendorPlace.new(vendor: vendor, place: place)
                       end

        nearby_place.distance = distance

        context.nearby_places << nearby_place
      end
    end

    private

    def google_map_key
      @google_map_key ||= ENV.fetch('GOOGLE_MAP_KEY')
    end

    def fetch_nearby_places
      url = URI("#{GOOGLE_MAP_API_URL}/place/nearbysearch/json?location=#{vendor.lat}%2C#{vendor.lon}&radius=5000&key=#{google_map_key}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      response = https.request(request)
      JSON.parse(response.read_body)
    end
  end
end
