require 'spec_helper'

RSpec.describe 'Cart API', type: :request do
  include_context "Storefront API v2"

  describe 'GET /api/v2/storefront/cart' do
    context 'when order_token is provided' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }

      let!(:cart_order_1) { create(:order, user: user1, state: 'cart') }
      let!(:payment_order_2) { create(:order, user: user1, state: 'payment') }
      let!(:payment_order_3) { create(:order, user: user2, state: 'payment') }

      context 'when the user is logged in & order belong to user' do
        it 'return order' do
          get '/api/v2/storefront/cart', params: { order_token: cart_order_1.token }, headers: signed_in_headers(user1)

          expect(response).to have_http_status(:success)
          expect(json_response_body["data"]["id"]).to eq cart_order_1.id.to_s
        end
      end

      context 'when the user is logged in & order does not belong to user' do
        it 'return forbidden' do
          get '/api/v2/storefront/cart', params: { order_token: payment_order_3.token }, headers: signed_in_headers(user1)

          expect(response).to have_http_status(:forbidden)
          expect(json_response_body['error']).to eq('You are not authorized to access this page.')
        end
      end

      context 'when the user is not log in' do
        it 'return order even order has user (follow spree ability for now)' do
          get '/api/v2/storefront/cart', params: { order_token: cart_order_1.token }

          expect(response).to have_http_status(:success)
          expect(json_response_body["data"]["id"]).to eq cart_order_1.id.to_s
        end
      end
    end

    context 'when order_token is NOT provided' do
      context 'when the user is logged in' do
        let(:user) { create(:user) }
        let!(:order_1) { create(:order, user: user, state: 'cart') }
        let!(:order_2) { create(:order, user: user, state: 'payment') }

        it 'return latest order' do
          get '/api/v2/storefront/cart', headers: signed_in_headers(user)

          expect(response).to have_http_status(:success)
          expect(json_response_body["data"]["id"]).to eq order_2.id.to_s
        end
      end

      context 'when the user is not log in' do
        it 'return 404' do
          get '/api/v2/storefront/cart'

          expect(response).to have_http_status(:not_found)
          expect(json_response_body['error']).to eq('The resource you were looking for could not be found.')
        end
      end
    end

    context 'when order is complete' do
      let!(:complete_order) { create(:order, state: 'complete', completed_at: Date.current) }

      # better to return for frontend to validate & old API didn't do that.
      it 'return the order even it is complete' do
        get '/api/v2/storefront/cart', params: { order_token: complete_order.token }

        expect(response).to have_http_status(:success)
        expect(json_response_body["data"]["id"]).to eq complete_order.id.to_s
        expect(json_response_body["data"]["attributes"]["state"]).to eq "complete"
      end
    end
  end
end
