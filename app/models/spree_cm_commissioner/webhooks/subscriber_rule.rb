module SpreeCmCommissioner
  module Webhooks
    class SubscriberRule < Base
      belongs_to :subscriber, class_name: 'Spree::Webhooks::Subscriber', inverse_of: :rules

      def supported?(_event)
        raise 'supported? should be implemented in a sub-class of SpreeCmCommissioner::Webhooks::SubscriberRule'
      end

      def matches?(_webhook_payload_body, _options = {})
        raise 'matches? should be implemented in a sub-class of SpreeCmCommissioner::Webhooks::SubscriberRule'
      end
    end
  end
end
