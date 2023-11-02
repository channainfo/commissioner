module SpreeCmCommissioner
  module Webhooks
    module SubscriberRulable
      extend ActiveSupport::Concern

      MATCH_POLICIES = %i[all any].freeze

      SUPPORTED_RULE_TYPES = [
        SpreeCmCommissioner::Webhooks::Rules::OrderStates,
        SpreeCmCommissioner::Webhooks::Rules::OrderVendors
      ].map(&:to_s)

      included do
        enum match_policy: MATCH_POLICIES, _prefix: true

        has_many :rules, autosave: true, dependent: :destroy, class_name: 'SpreeCmCommissioner::Webhooks::SubscriberRule'
      end

      def available_rule_types
        existing = rules.pluck(:type)

        SUPPORTED_RULE_TYPES.reject { |r| existing.include? r }
      end

      def match_all?
        match_policy == 'all'
      end

      def match_any?
        match_policy == 'any'
      end

      def matches?(event, webhook_payload_body, options = {})
        # Subscriber without rules are always match by default.
        return true if rules.none?

        # Reject if event is not supported by rules
        supported_rules = rules.select { |rule| rule.supported?(event) }
        return false if supported_rules.none?

        if match_all?
          supported_rules.all? do |rule|
            rule.matches?(event, webhook_payload_body, options)
          end
        elsif match_any?
          supported_rules.any? do |rule|
            rule.matches?(event, webhook_payload_body, options)
          end
        end
      end
    end
  end
end
