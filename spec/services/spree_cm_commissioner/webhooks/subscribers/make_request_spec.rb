require "spec_helper"

RSpec.describe SpreeCmCommissioner::Webhooks::Subscribers::MakeRequest do
  describe '#headers' do
    let(:request ) {  described_class.new(signature: 'fake-signature', url: 'fake-url.com/create', api_key: 'fake-api-key', webhook_payload_body: {"id": "fake"}) }

    subject { request.headers }

    it { is_expected.to include('Content-Type' => 'application/json') }
    it { is_expected.to include('X-Api-Key' => 'fake-api-key') }
    it { is_expected.to include('X-Spree-Hmac-SHA256' => 'fake-signature') }
  end
end
