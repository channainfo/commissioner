require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::FeedbackReviewsController, type: :controller do
  let!(:review_user) { create(:cm_user) }
  let!(:feedback_review_user) { create(:cm_user) }

  let(:product) { create(:cm_product ) }

  let!(:review) {create(:review , user_id: review_user.id , product_id: product.id)}

  describe 'POST create' do

    before(:each) do
      allow(controller).to receive(:spree_current_user).and_return(feedback_review_user)
    end

    it 'return status code 201 when create success' do

      params = {
        rating: 4,
        comment: 'Yeah I think so',
        review_id: review.id
      }
      post :create, params: params

      expect(response.status).to eq 201
    end

    it 'return status code 404 when review_id not found' do

      params = {
        rating: 4,
        comment: 'Yeah I think so',
        review_id: 0
      }

      post :create, params: params

      expect(response.status).to eq 404
    end
  end
end