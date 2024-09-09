require 'spec_helper'

RSpec.describe SpreeCmCommissioner::WebhookSubscriberOrdersSenderJob, type: :job do
  describe "#perform" do
    let(:order_state) { 'complete' }
    let(:webhooks_subscriber) { create(:cm_webhook_subscriber) }

    it "send orders to webhook subscriber" do
      allow(Spree::Webhooks::Subscriber).to receive(:find).with(webhooks_subscriber.id).and_return(webhooks_subscriber)
      allow(SpreeCmCommissioner::WebhookSubscriberOrdersSender).to receive(:call)
                                                              .with(order_state: order_state, webhooks_subscriber: webhooks_subscriber)
                                                              .and_return(webhooks_subscriber)

      described_class.perform_now(order_state: order_state, webhooks_subscriber_id: webhooks_subscriber.id)

      expect(Spree::Webhooks::Subscriber).to have_received(:find).with(webhooks_subscriber.id)
      expect(SpreeCmCommissioner::WebhookSubscriberOrdersSender).to have_received(:call).with(
        order_state: order_state,
        webhooks_subscriber: webhooks_subscriber
      )
    end
  end
end
