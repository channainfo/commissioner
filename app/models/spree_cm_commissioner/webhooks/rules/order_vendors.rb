module SpreeCmCommissioner
  module Webhooks
    module Rules
      class OrderVendors < SubscriberRule
        MATCH_POLICIES = %w[any all].freeze

        SUPPORTED_EVENTS = [
          'order.create',
          'order.delete',
          'order.update',
          'order.canceled',
          'order.placed',
          'order.resumed',
          'order.shipped'
        ].freeze

        preference :match_policy, :string, default: MATCH_POLICIES.first
        preference :vendors, :array

        def supported?(event)
          SUPPORTED_EVENTS.include?(event)
        end

        def matches?(webhook_payload_body, _options = {})
          return false if preferred_vendors.empty?

          payload_body = JSON.parse(webhook_payload_body)

          vendor_ids = payload_body['included'].filter_map do |include|
            include['attributes']['vendor_id'].to_s if include['type'] == 'line_item'
          end

          return false if vendor_ids.empty?

          case preferred_match_policy
          when 'any'
            preferred_vendors.any? { |vendor_id| vendor_ids.include?(vendor_id) }
          when 'all'
            preferred_vendors.all? { |vendor_id| vendor_ids.include?(vendor_id) }
          end
        end
      end
    end
  end
end
