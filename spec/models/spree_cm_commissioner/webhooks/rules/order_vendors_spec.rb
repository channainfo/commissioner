require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Webhooks::Rules::OrderVendors, type: :model do
  describe '#matches?' do
    let(:vendor1) { create(:vendor) }
    let(:vendor2) { create(:vendor) }
    let(:vendor3) { create(:vendor) }

    let(:order) { create(:order_with_line_items, line_items_count: 2) }

    before do
      allow(order.line_items[0]).to receive(:vendor_id).and_return(vendor1.id)
      allow(order.line_items[1]).to receive(:vendor_id).and_return(vendor2.id)
    end

    context 'all' do
      it 'matched when all preferred vendors are in order' do
        rule =  build(:cm_webhook_subscriber_order_vendors_rule, vendors: [vendor1, vendor2], match_policy: 'all')
        matched = rule.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be true
      end

      it 'reject when one of preferred vendors is not in order' do
        rule =  build(:cm_webhook_subscriber_order_vendors_rule, vendors: [vendor1, vendor2, vendor3], match_policy: 'all')
        matched = rule.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be false
      end
    end

    context 'any' do
      it 'matched when one preferred vendors is in order' do
        rule =  build(:cm_webhook_subscriber_order_vendors_rule, vendors: [vendor1], match_policy: 'all')
        matched = rule.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be true
      end

      it 'reject when none of preferred venodrs is in order' do
        rule =  build(:cm_webhook_subscriber_order_vendors_rule, vendors: [vendor3], match_policy: 'all')
        matched = rule.matches?('order.placed', order.send(:webhook_payload_body), **order.send(:webhooks_request_options))

        expect(matched).to be false
      end
    end
  end
end
