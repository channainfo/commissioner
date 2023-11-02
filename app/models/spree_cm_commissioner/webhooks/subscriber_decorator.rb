module SpreeCmCommissioner
  module Webhooks
    module SubscriberDecorator
      def self.prepended(base)
        base.include SpreeCmCommissioner::Webhooks::SubscriberRulable
      end
    end
  end
end

unless Spree::Webhooks::Subscriber.included_modules.include?(SpreeCmCommissioner::Webhooks::SubscriberDecorator)
  Spree::Webhooks::Subscriber.prepend(SpreeCmCommissioner::Webhooks::SubscriberDecorator)
end
