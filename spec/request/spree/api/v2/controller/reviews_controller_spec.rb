require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::ReviewsController, type: :controller do
  let!(:user) { create(:cm_user) }
  let(:product) { create(:cm_product ) }

  describe 'POST create' do
    before(:each) do
      allow(controller).to receive(:spree_current_user).and_return(user)
    end

    it 'return status code 201 when create success' do
      params = {
          product_id: product.id,
          rating: 4,
          title: 'My Review on Sai Event',
          name: 'John',
          review: 'The event is fun',
          show_identifier: 1
      }

      post :create, params: params

      expect(response.status).to eq 201
    end

    it 'return status code 404 when product is nil' do
      params = {
          rating: 4,
          title: 'My Review on Sai Event',
          name: 'John',
          review: 'The event is fun',
          show_identifier: 1
      }

      post :create, params: params

      expect(response.status).to eq 404
    end

    it 'return status code 400 when create fail' do
      params = {
        product_id: product.id,
      }

      post :create, params: params

      expect(response.status).to eq 400
    end
  end
end