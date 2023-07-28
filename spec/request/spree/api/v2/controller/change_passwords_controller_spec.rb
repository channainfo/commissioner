

require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::ChangePasswordsController, type: :controller do
  let(:user) { create(:cm_user) }
  let!(:current_password) { '12345678' }
  let!(:new_password) { '87654321' }

  before(:each) do
    allow(controller).to receive(:spree_current_user).and_return(user)
  end

  context 'with vaild params' do
    it 'change user password successfully' do
      user.password = current_password
      user.password_confirmation = current_password
      user.save!

      options = {
        current_password: current_password,
        password: new_password,
        password_confirmation: new_password
      }

      put :update, params: options
      user.reload

      expect(response.status).to eq 200

    end

    it 'fails to change password' do
      user.password = current_password
      user.password_confirmation = current_password
      user.save!

      before_update = user.updated_at

      options = {
        current_password: 'invalid',
        password: new_password,
        password_confirmation: new_password
      }

      put :update, params: options
      user.reload

      expect(response.status).to eq 422
      expect(json_response_body).to eq({ 'error' => 'Incorrect password' })

    end
  end
end