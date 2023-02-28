module SpreeCmCommissioner
  class NearbyPlacesLoader < BaseInteractor
    delegate :vendor, to: :context

    def call
      json_response = request

      json_response['results'].each_with_index do |json, index|
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

        place.save! if place.changed?
        NearbyPlaceDistanceFinder.call(vendor: vendor, place: place, index: index)
      end
    end

    def google_map_key
      @google_map_key ||= ENV.fetch('GOOGLE_MAP_KEY')
    end

    def request
      url = URI("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{vendor.lat}%2C#{vendor.lon}&radius=5000&key=#{google_map_key}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      response = https.request(request)
      JSON.parse(response.read_body)
    end
  end
end
