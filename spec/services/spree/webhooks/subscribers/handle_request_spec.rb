require "spec_helper"

RSpec.describe Spree::Webhooks::Subscribers::HandleRequest do
  let(:subscriber) { create(:cm_webhook_subscriber) }

  describe '#request' do
    subject { described_class.new(event_name: 'any.event', subscriber: subscriber, webhook_payload_body: '{"id": "fake"}') }

    let(:fake_payload_body) { subject.send(:body_with_event_metadata) }
    let(:event) { subject.send(:event) }

    it 'construct make_request instance with singature' do
      signature = event.signature_for(fake_payload_body)

      expect(Spree::Webhooks::Subscribers::MakeRequest).to receive(:new)
        .with(
          signature: signature,
          url: subscriber.url,
          api_key: subscriber.api_key,
          webhook_payload_body: fake_payload_body
        )

      subject.request
    end
  end
end
