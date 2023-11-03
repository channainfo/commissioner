module SpreeCmCommissioner
  module Webhooks
    module SubscriberDecorator
      def self.prepended(base)
        base.include SpreeCmCommissioner::Webhooks::SubscriberRulable

        def base.authorized?(name, api_key)
          find_by(name: name, api_key: api_key).present?
        end
      end
    end
  end
end

unless Spree::Webhooks::Subscriber.included_modules.include?(SpreeCmCommissioner::Webhooks::SubscriberDecorator)
  Spree::Webhooks::Subscriber.prepend(SpreeCmCommissioner::Webhooks::SubscriberDecorator)
end
