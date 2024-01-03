require 'spec_helper'

RSpec.describe Spree::Webhooks::Subscriber, type: :model do
  describe '.authorized?' do
    let!(:subscriber) { create(:cm_webhook_subscriber, name: "SubName", api_key: "SubToken") }

    it 'return true when api_key and name is found' do
      authorized = described_class.authorized?('SubName', 'SubToken')
      expect(authorized).to be true
    end

    it 'return false when name is not found' do
      authorized = described_class.authorized?('WrongName', 'SubToken')
      expect(authorized).to be false
    end

    it 'return false when api_key is not found' do
      authorized = described_class.authorized?('SubName', 'WrongToken')
      expect(authorized).to be false
    end

    it 'return false both name & api_key is not found' do
      authorized = described_class.authorized?('WrongName', 'WrongToken')
      expect(authorized).to be false
    end
  end

  describe '#secret_key' do
    it 'does not generate secret_key on build' do
      subscriber = build(:cm_webhook_subscriber)

      expect(subscriber.secret_key).to be_nil
    end

    it 'generate secret_key on create' do
      subscriber = create(:cm_webhook_subscriber)

      expect(subscriber.secret_key).not_to be_nil
    end
  end

  describe '#matches?' do
    let(:order) { build(:order) }
    let(:rule1) { build(:cm_webhook_subscriber_order_vendors_rule) }
    let(:rule2) { build(:cm_webhook_subscriber_order_states_rule) }
    let(:subscriber) { build(:cm_webhook_subscriber, rules: [rule1, rule2]) }

    it 'reject when event is not suppported' do
      event = 'order.fake-event'

      matched = subscriber.matches?(event, order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

      expect(matched).to eq false
      expect(rule1.supported?(event)).to eq false
      expect(rule2.supported?(event)).to eq false
    end

    it 'matched when subscriber has no rules' do
      subscriber.rules = []

      matched = subscriber.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

      expect(matched).to eq true
      expect(subscriber.rules).to eq []
    end

    context 'any' do
      it 'matched when one of rules are matched' do
        allow(subscriber).to receive(:match_policy).and_return('any')

        allow(rule1).to receive(:matches?).and_return(true)
        allow(rule2).to receive(:matches?).and_return(false)

        matched = subscriber.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be true
        expect(subscriber.match_any?).to be true
      end

      it 'matched when all rules are matched' do
        allow(subscriber).to receive(:match_policy).and_return('any')

        allow(rule1).to receive(:matches?).and_return(true)
        allow(rule2).to receive(:matches?).and_return(true)

        matched = subscriber.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be true
        expect(subscriber.match_any?).to be true
      end

      it 'reject when no rules are matched' do
        allow(subscriber).to receive(:match_policy).and_return('any')

        allow(rule1).to receive(:matches?).and_return(false)
        allow(rule2).to receive(:matches?).and_return(false)

        matched = subscriber.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be false
        expect(subscriber.match_any?).to be true
      end
    end

    context 'all' do
      it 'matched when all rules are matched' do
        allow(subscriber).to receive(:match_policy).and_return('all')

        allow(rule1).to receive(:matches?).and_return(true)
        allow(rule2).to receive(:matches?).and_return(true)

        matched = subscriber.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be true
        expect(subscriber.match_all?).to be true
      end

      it 'reject when one of rules is not matched' do
        allow(subscriber).to receive(:match_policy).and_return('all')

        allow(rule1).to receive(:matches?).and_return(true)
        allow(rule2).to receive(:matches?).and_return(false)

        matched = subscriber.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be false
        expect(subscriber.match_all?).to be true
      end
    end
  end

  describe '#authorized_to?' do
    let(:vendor) { create(:vendor) }
    let(:order) { create(:order_with_line_items, line_items_count: 1) }

    it 'return failed when no authorized rules is added' do
      non_authorizer_rule = build(:cm_webhook_subscriber_order_states_rule)
      subscriber = build(:cm_webhook_subscriber, rules: [non_authorizer_rule])

      expect(subscriber.authorizer_rules.size).to eq 0
      expect(subscriber.authorized_to?(order)).to eq false
    end

    it 'return true when subscriber authorized to vendor' do
      allow(order.line_items[0]).to receive(:vendor_id).and_return(vendor.id)

      authorizer_rule = create(:cm_webhook_subscriber_order_vendors_rule, vendors: [vendor], match_policy: 'all')
      subscriber = create(:cm_webhook_subscriber, rules: [authorizer_rule])

      expect(subscriber.authorizer_rules).to eq [authorizer_rule]
      expect(subscriber.authorized_to?(order)).to be true
    end

    it 'return false when subscriber does not authorized to vendor' do
      allow(order.line_items[0]).to receive(:vendor_id).and_return(vendor.id)

      authorizer_rule = create(:cm_webhook_subscriber_order_vendors_rule, vendors: [], match_policy: 'all')
      subscriber = create(:cm_webhook_subscriber, rules: [authorizer_rule])

      expect(subscriber.authorizer_rules).to eq [authorizer_rule]
      expect(subscriber.authorized_to?(order)).to be false
    end
  end
end
