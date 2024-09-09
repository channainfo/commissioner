require 'spec_helper'

RSpec.describe Spree::Admin::BaseController, type: :controller do
  let!(:user) { create(:user) }
  let!(:billing_store) { create(:store, code: 'billing') }

  controller(Spree::Admin::BaseController) do
    def index
      render plain: 'Admin Dashboard'
    end
  end

  describe 'GET #index' do
    before(:each) do
      allow(Spree::Store).to receive(:default).and_return(billing_store)
      allow(controller).to receive(:spree_current_user).and_return(user)
      user.spree_roles << create(:role, name: 'admin')
    end

    context 'when user does not have super_admin role and store is billing' do
      before do
        allow(user).to receive(:super_admin?).and_return(false)
        get :index
      end

      it 'redirects to billing' do
        expect(response).to redirect_to(billing_root_path)
      end
    end

    context 'when user has super_admin role and store is billing' do
      before do
        allow(user).to receive(:super_admin?).and_return(true)
        get :index
      end

      it 'allows access to admin dashboard' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('Admin Dashboard')
      end
    end
  end
end
