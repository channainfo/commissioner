require 'spec_helper'

RSpec.describe SpreeCmCommissioner::QueueOrderWebhooksRequestsJob, type: :job do
  describe "#perform" do
    let(:event) { 'order.placed' }
    let(:order) { create(:order) }

    it "queues webhooks requests" do
      allow(Spree::Order).to receive(:find).with(order.id).and_return(order)
      allow(order).to receive(:queue_webhooks_requests!).with(event)

      described_class.perform_now({ order_id: order.id, event: event })

      expect(Spree::Order).to have_received(:find).with(order.id)
      expect(order).to have_received(:queue_webhooks_requests!).with(event)
    end
  end
end
