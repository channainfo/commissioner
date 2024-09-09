require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::AccountDeletionsController, type: :controller do
  describe 'DELETE #delete' do
    let(:user) { create(:cm_user) }
    let!(:user_password) { '12345678' }
    let(:reason) { create(:user_deletion_reason) }

    before(:each) do
      allow(controller).to receive(:spree_current_user).and_return(user)
      user.password = user_password
      user.password_confirmation = user_password
      user.save!
    end

    context 'with invalid params' do

      it 'return error message when params is missing' do

        delete :destroy, params: { password: user_password }

        expect(json_response_body['error']).to eq 'param is missing or the value is empty: user_deletion_reason_id'
      end
    end

    context 'with valid params' do

      it 'return 200 & save survey when params is valid' do
        delete :destroy, params: {
          password: user_password,
          user_deletion_reason_id: reason.id,
        }

        user.reload
        survey = SpreeCmCommissioner::UserDeletionSurvey.last

        expect(user.normal_user?).to eq true
        expect(response.status).to eq 200
        expect(survey.user_deletion_reason_id).to eq reason.id
      end
    end
  end
end