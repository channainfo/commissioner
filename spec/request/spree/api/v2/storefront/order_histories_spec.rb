require 'spec_helper'

RSpec.describe 'OrderHistories API', type: :request do
  include_context "Storefront API v2"

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:guest_user) { nil }

  let!(:cart_order_1) { create(:order, user: user1, state: 'cart') }
  let!(:payment_order_2) { create(:order, user: user1, state: 'payment') }
  let!(:payment_order_3) { create(:order, user: user2, state: 'payment') }
  let!(:payment_order_anon_3) { create(:order, user: guest_user, state: 'payment') }

  describe 'GET /api/v2/storefront/order_histories' do
    context 'when the user is logged in' do
      it 'returns user orders with state :payment' do
        get '/api/v2/storefront/order_histories', headers: signed_in_headers(user1)

        expect(response).to have_http_status(:success)
        expect(json_response_body["data"].length).to eq 1
        expect(json_response_body["data"][0]["id"]).to eq payment_order_2.id.to_s
      end
    end

    context 'when the user is a guest' do
      it 'returns orders based on the provided order tokens' do
        get '/api/v2/storefront/order_histories', params: { 'order_tokens[]': [payment_order_anon_3.token] }

        expect(response).to have_http_status(:success)
        expect(json_response_body["data"].length).to eq(1)
        expect(json_response_body["data"][0]["id"]).to eq payment_order_anon_3.id.to_s
      end
    end

    context 'when neither user nor order tokens are provided' do
      it 'returns no orders' do
        get '/api/v2/storefront/order_histories'

        expect(response).to have_http_status(:success)
        expect(json_response_body["data"].length).to eq 0
      end
    end
  end

  describe 'PATCH /api/v2/storefront/order_histories/:id/archive' do
    context 'when the user is logged in & try to archive their own order with :payment state' do
      it 'archives the order' do
        patch "/api/v2/storefront/order_histories/#{payment_order_2.token}/archive", headers: signed_in_headers(user1)

        expect(response).to have_http_status(:success)
        expect(payment_order_2.reload.archived_at).not_to be_nil
      end
    end

    context 'when the user tries to archive their order that is not in payment state' do
      it 'returns an error' do
        patch "/api/v2/storefront/order_histories/#{cart_order_1.token}/archive", headers: signed_in_headers(user1)

        expect(response).to have_http_status(:forbidden)
        expect(json_response_body['error']).to eq('You are not authorized to access this page.')
      end
    end

    context 'when the user tries to archive another user order' do
      it 'returns an error' do
        patch "/api/v2/storefront/order_histories/#{cart_order_1.token}/archive", headers: signed_in_headers(user2)

        expect(response).to have_http_status(:forbidden)
        expect(json_response_body['error']).to eq('You are not authorized to access this page.')
      end
    end
  end
end
