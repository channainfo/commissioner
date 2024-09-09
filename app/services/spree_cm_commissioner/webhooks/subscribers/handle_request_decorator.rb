module SpreeCmCommissioner
  module Webhooks
    module Subscribers
      module HandleRequestDecorator
        def self.prepended(_base)
          delegate :api_key, to: :subscriber
        end

        # override
        def request
          @request ||=
            SpreeCmCommissioner::Webhooks::Subscribers::MakeRequest.new(url: url, api_key: api_key, webhook_payload_body: body_with_event_metadata)
        end
      end
    end
  end
end

Spree::Webhooks::Subscribers::HandleRequest.prepend SpreeCmCommissioner::Webhooks::Subscribers::HandleRequestDecorator
