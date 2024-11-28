module SpreeCmCommissioner
  class GooglePlacesFetcher < BaseInteractor
    delegate :name, to: :context

    def call
      json_response = fetch_google_place_by_name

      context.google_places = json_response['results'].map do |json|
        SpreeCmCommissioner::Place.new(
          reference: json['reference'],
          types: json['types'].blank? ? '' : json['types'][0],
          name: json['name'],
          vicinity: json['vicinity'],
          lat: json['geometry']['location']['lat'],
          lon: json['geometry']['location']['lng'],
          icon: json['icon'],
          rating: json['rating']
        )
      end
    end

    private

    def google_map_key
      @google_map_key ||= ENV.fetch('GOOGLE_MAP_KEY')
    end

    def fetch_google_place_by_name
      queries = {
        query: name,
        key: google_map_key
      }
      response = Faraday.get("#{GOOGLE_MAP_API_URL}/place/textsearch/json", queries)
      JSON.parse(response.body)
    end
  end
end
