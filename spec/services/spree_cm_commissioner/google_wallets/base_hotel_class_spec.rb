require 'spec_helper'

RSpec.describe SpreeCmCommissioner::GoogleWallets::BaseHotelClass do
  let(:google_wallet_class) {
    instance_double(
      'google_wallet_class',
      class_id: 'class_id',
      preferred_issuer_name: 'issuer_name',
      preferred_hotel_name: 'hotel_name',
      preferred_hotel_address: 'hotel_address',
      preferred_background_color: 'background_color',
      logo: double('logo'),
      hero_image: double('hero_image'),
    )
  }
  let(:instance) { described_class.new(google_wallet_class) }

  before do
    allow(ENV).to receive(:fetch).with('ISSUER_ID', nil).and_return('issuer_id')
    allow(instance).to receive(:rails_blob_url).with(google_wallet_class.logo).and_return('logo_url')
    allow(instance).to receive(:rails_blob_url).with(google_wallet_class.hero_image).and_return('hero_image_url')
  end

  describe '#call' do
    let(:response) { double('response', code: 200) }

    before do
      allow(instance).to receive(:send_request).and_return(response)
    end

    it 'returns the response status' do
      expect(instance.call).to eq({ status: 200 })
    end
  end

  describe '#send_request' do
    it 'raises NotImplementedError' do
      expect { instance.send_request }.to raise_error(NotImplementedError, 'send_request must be implemented in subclasses')
    end
  end

  describe '#issuer_id' do
    it 'returns the issuer ID from environment variables' do
      expect(instance.issuer_id).to eq('issuer_id')
    end
  end

  describe '#class_id' do
    it 'returns the full class ID' do
      expect(instance.class_id).to eq('issuer_id.class_id')
    end
  end

  describe '#issuer_name' do
    it 'returns the issuer name' do
      expect(instance.issuer_name).to eq('issuer_name')
    end
  end

  describe '#hotel_name' do
    it 'returns the hotel name' do
      expect(instance.hotel_name).to eq('hotel_name')
    end
  end

  describe '#hotel_address' do
    it 'returns the hotel address' do
      expect(instance.hotel_address).to eq('hotel_address')
    end
  end

  describe '#background_color' do
    it 'returns the background color' do
      expect(instance.background_color).to eq('background_color')
    end
  end

  describe '#logo' do
    it 'returns the URL for the logo' do
      expect(instance.logo).to eq('logo_url')
    end
  end

  describe '#hero_image' do
    it 'returns the URL for the hero image' do
      expect(instance.hero_image).to eq('hero_image_url')
    end
  end

  describe '#build_request_body' do
    it 'returns the correct request body' do
      expected_body = {
        id: 'issuer_id.class_id',
        issuerId: 'issuer_id',
        imageModulesData: [
          {
            mainImage: {
              sourceUri: {
                id: 'logo',
                uri: 'logo_url'
              }
            }
          }
        ],
        textModulesData: [
          {
            header: 'Hotel Name',
            body: 'hotel_name'
          },
          {
            header: 'Hotel Address',
            body: 'hotel_address'
          },
          {
            header: 'Background Color',
            body: 'background_color'
          }
        ]
      }.to_json

      expect(instance.build_request_body).to eq(expected_body)
    end
  end
end
