require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::UserRegistrationWithSocialsController, type: :controller do
  routes { Spree::Core::Engine.routes }

  describe '#create' do
    it 'success return oauth token object' do
      set_application_token

      id_token = 'valid_id_token'
      user = create(:user)

      user_context = double(:user_context, success?: true, user: user)
      allow(SpreeCmCommissioner::UserRegistrationWithSocial).to receive(:call).and_return(user_context)

      post :create, params: { id_token: id_token }
      expect(response.status).to eq 200
    end
  end
end