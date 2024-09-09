module SpreeCmCommissioner
  module GoogleWallets
    class EventTicketClassUpdater < BaseEventTicketClass
      def send_request
        uri = URI.parse("#{GOOGLE_API_ENDPOINT}/#{class_id}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Patch.new(uri)
        request['Authorization'] = "Bearer #{access_token}"
        request['Content-Type'] = 'application/json'
        request.body = build_request_body

        http.request(request)
      end
    end
  end
end
