module SpreeCmCommissioner
  module GoogleWallets
    class HotelClassCreator < BaseHotelClass
      # override
      def send_request
        uri = URI.parse(GOOGLE_API_ENDPOINT)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Bearer #{access_token}"
        request['Content-Type'] = 'application/json'
        request.body = build_request_body

        http.request(request)
      end
    end
  end
end
