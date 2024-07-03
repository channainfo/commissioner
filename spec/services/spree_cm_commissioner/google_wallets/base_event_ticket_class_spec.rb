require 'spec_helper'

RSpec.describe SpreeCmCommissioner::GoogleWallets::BaseEventTicketClass do
  let(:product) { create(:cm_product ) }
  let(:image) { create(:cm_image) }

  let(:google_wallet_class) { instance_double('SpreeCmCommissioner::EventTicketGoogleWallet',
                                              class_id: 'product_slug_class_id',
                                              preferred_issuer_name: 'BookMe+',
                                              preferred_event_name: 'Run with Sai Event',
                                              preferred_venue_name: 'National Park',
                                              preferred_venue_address: 'Kampot Province',
                                              preferred_start_date: '2024-08-12',
                                              preferred_end_date: '2024-08-13',
                                              preferred_background_color: '#FFFFFF',
                                              logo: image,
                                              hero_image: image,
                                              product: product
                                              ) }

  let(:creator) { described_class.new(google_wallet_class) }

  describe '#class_id' do
    it 'returns correct class_id format' do
      allow(ENV).to receive(:fetch).with('ISSUER_ID', nil).and_return('issuer_id')

      expect(creator.class_id).to eq "issuer_id.#{google_wallet_class.class_id}"
    end
  end

  describe '#date_format' do
    it 'returns correct datetime format for start_date' do
      formatted_date = creator.send(:date_format, google_wallet_class.preferred_start_date)

      expect(formatted_date).to eq '2024-08-12T00:00'
    end

    it 'returns correct datetime format for end_date' do
      formatted_date = creator.send(:date_format, google_wallet_class.preferred_end_date)

      expect(formatted_date).to eq '2024-08-13T00:00'
    end
  end

  describe '#build_request_body' do
    it 'builds the correct request body' do
        request_body = creator.send(:build_request_body)

        expect(JSON.parse(request_body)['issuerName']).to eq('BookMe+')
        expect(JSON.parse(request_body)['eventName']).to eq( {"defaultValue"=>{"language"=>"en-US", "value"=>"Run with Sai Event"}} )
        expect(JSON.parse(request_body)['dateTime']).to eq( {"end"=>"2024-08-13T00:00", "start"=>"2024-08-12T00:00"} )
        expect(JSON.parse(request_body)['reviewStatus']).to eq 'UNDER_REVIEW'
        expect(JSON.parse(request_body)['hexBackgroundColor']).to eq '#FFFFFF'
      end
    end
end
