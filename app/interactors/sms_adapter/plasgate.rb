module SmsAdapter
  module Plasgate
    # options: to:, :from, :body
    def create_message(options)
      response = client.post('/rest/send') do |req|
        req.params = { private_key: Rails.application.credentials.plasgate[:private] }
        req.body = request_body(options).to_json
      end

      raise response.body if response.status != 200

      JSON.parse(response.body)
    end

    def client
      host = 'https://cloudapi.plasgate.com'
      @client = Faraday.new(
        url: host,
        ssl: { verify: false },
        headers: {
          'X-Secret' => Rails.application.credentials.plasgate[:secret],
          'Content-Type' => 'application/json'
        }
      )
      @client
    end

    def adapter_name
      'Plasgate'
    end

    private

    # options: to:, :from, :body
    def request_body(options)
      to = options[:to].gsub('+', '')
      {
        sender: options[:from],
        to: to,
        content: options[:body]
      }
    end
  end
end
