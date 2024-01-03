# frozen_string_literal: true

module SpreeCmCommissioner
  module Webhooks
    module Subscribers
      class MakeRequest < Spree::Webhooks::Subscribers::MakeRequest
        attr_reader :api_key

        def initialize(signature:, url:, api_key:, webhook_payload_body:)
          @api_key = api_key
          super(signature: signature, url: url, webhook_payload_body: webhook_payload_body)
        end

        def headers
          headers = {}

          headers['Content-Type'] = 'application/json'
          headers['X-Api-Key'] = api_key if api_key.present?
          headers['X-Spree-Hmac-SHA256'] = @signature

          headers
        end

        # overrided
        def request
          req = Net::HTTP::Post.new(uri_path, headers)
          req.body = webhook_payload_body
          @request ||= begin
            start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            request_result = http.request(req)
            @execution_time_in_milliseconds = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time).in_milliseconds
            request_result
          end
        rescue Errno::ECONNREFUSED, Net::ReadTimeout, SocketError
          Class.new do
            def self.code
              '0'
            end
          end
        end
      end
    end
  end
end
