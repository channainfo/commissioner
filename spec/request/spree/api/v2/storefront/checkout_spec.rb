require 'spec_helper'

RSpec.describe 'Checkout API', type: :request do
  include_context "Storefront API v2"

  describe 'GET /api/v2/storefront/checkout/next' do
    context 'when order_token is provided' do
      let(:user1) { create(:user) }
      let!(:cart_order_1) { create(:order_with_line_items, user: user1, state: 'cart') }

      context 'when the user is logged in & order belong to user' do
        it 'find order & move order to next state' do
          patch '/api/v2/storefront/checkout/next', params: { order_token: cart_order_1.token }, headers: signed_in_headers(user1)

          expect(response).to have_http_status(:success)
          expect(json_response_body["data"]["id"]).to eq cart_order_1.id.to_s
          expect(json_response_body["data"]["attributes"]["state"]).to eq "address"
        end
      end
    end
  end
end
