require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Webhooks::Rules::OrderStates, type: :model do
  describe '#matches?' do
    let(:order) { create(:order, state: :complete) }

    it 'matched when order state is in rule states' do
      rule = build(:cm_webhook_subscriber_order_states_rule, states: ['complete'])
      matched = rule.matches?(order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

      expect(matched).to be true
    end

    it 'reject when order state is no in rule states' do
      rule = build(:cm_webhook_subscriber_order_states_rule, states: ['canceled'])
      matched = rule.matches?(order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

      expect(matched).to be false
    end
  end
end
