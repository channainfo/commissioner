module SpreeCmCommissioner
  module Webhooks
    module Subscribers
      module QueueRequestsDecorator
        # override
        def filtered_subscribers(event_name, webhook_payload_body, options)
          Spree::Webhooks::Subscriber.active.with_urls_for(event_name).select do |subscriber|
            subscriber.matches?(event_name, webhook_payload_body, options)
          end
        end
      end
    end
  end
end

Spree::Webhooks::Subscribers::QueueRequests.prepend SpreeCmCommissioner::Webhooks::Subscribers::QueueRequestsDecorator
