require 'spec_helper'
RSpec.describe Spree::Api::V2::Storefront::UserProfilesController, type: :controller do
  let!(:user) { create(:cm_user, first_name: 'Chris', last_name: 'Evan') }
  describe 'POST update' do

    before(:each) do
      allow(controller).to receive(:spree_current_user).and_return(user)
    end

    it 'return status ok when update is successful' do
      set_resource_owner_token
      params = {
        last_name: 'Kevin',
        first_name: 'John',

      }
      put :update, params: params

      expect(response.status).to eq 200
      expect(user.reload).to have_attributes(
        last_name: 'Kevin',
        first_name: 'John',
      )
    end
  end
end