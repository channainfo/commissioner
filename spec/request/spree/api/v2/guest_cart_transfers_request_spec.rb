require 'spec_helper'

RSpec.describe 'Spree::Api::V2::Storefront::GuestCartTransfersController', type: :request do
  let(:oauth_token) { create_resource_owner_token }
  let(:user) { oauth_token.resource_owner }
  let(:headers) { { "Authorization" => "Bearer #{oauth_token.token}" } }

  let!(:store) { Spree::Store.default }
  let!(:currency) { store.default_currency }
  let!(:guest) { create(:cm_guest_user) }
  let(:guest_token) { SpreeCmCommissioner::UserJwtToken.encode({ user_id: guest.id }, guest.reload.secure_token) }
  let(:guest_id) { guest.id.to_s }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_store).and_return(store)
    allow_any_instance_of(ApplicationController).to receive(:current_currency).and_return(currency)
  end

  describe 'PUT /api/v2/storefront/guest_cart_transfer' do
    subject(:send_request) { put '/api/v2/storefront/guest_cart_transfer', params: params, headers: headers }

    context 'when the guest cart transfer is successful' do
      let(:params) do
        {
          guest_token: guest_token,
          guest_id: guest_id,
          merge_type: 'replace'
        }
      end

      before do
        create(:order, store: store, user: guest, currency: currency)
      end

      it 'calls SpreeCmCommissioner::GuestCartTransfer.call with correct parameters' do
        allow(SpreeCmCommissioner::GuestCartTransfer).to receive(:call).and_return(double(:context, success?: true, message: nil))

        send_request

        expect(SpreeCmCommissioner::GuestCartTransfer).to have_received(:call).with(
          store: store,
          currency: currency,
          guest_token: guest_token,
          guest_id: guest_id,
          user: user,
          merge_type: 'replace'
        )
      end

      it 'returns http status 200' do
        send_request

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the guest cart transfer fails' do
      let(:params) do
        {
          guest_token: 'invalid_guest_token',
          guest_id: guest_id,
          merge_type: 'replace'
        }
      end

      before do
        send_request
      end

      it 'returns http status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error message with guest is invalid' do
        expect(JSON.parse(response.body)['error']).to eq('Guest is invalid!')
      end
    end
  end
end
