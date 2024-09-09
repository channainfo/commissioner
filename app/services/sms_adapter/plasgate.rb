module SmsAdapter
  class Plasgate < Base
    # options: to:, :from, :body
    def create_message(options)
      response = request(options)

      raise response.body if response.status != 200

      json = JSON.parse(response.body)

      # update sms log
      yield(external_ref: json['queue_id'])

      json
    end

    def request(options)
      client.post('/rest/send') do |req|
        req.params = { private_key: Rails.application.credentials.plasgate[:private] }
        req.body = request_body(options).to_json
      end
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
