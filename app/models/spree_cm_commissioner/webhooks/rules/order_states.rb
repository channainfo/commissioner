module SpreeCmCommissioner
  module Webhooks
    module Rules
      class OrderStates < SubscriberRule
        SUPPORTED_EVENTS = [
          'order.create',
          'order.delete',
          'order.update',
          'order.canceled',
          'order.placed',
          'order.resumed',
          'order.shipped'
        ].freeze

        DEFAULT_STATES = %w[
          cart
          address
          payment
          complete
          delivery
          awaiting_return
          canceled
          returned
          resumed
        ].freeze

        preference :states, :array, default: DEFAULT_STATES

        def supported?(event)
          SUPPORTED_EVENTS.include?(event)
        end

        def matches?(webhook_payload_body, _options = {})
          payload_body = JSON.parse(webhook_payload_body)

          state = payload_body['data']['attributes']['state']

          preferred_states.include?(state)
        end
      end
    end
  end
end
