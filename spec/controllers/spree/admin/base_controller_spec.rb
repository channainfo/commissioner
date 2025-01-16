require 'spec_helper'

RSpec.describe Spree::Admin::BaseController, type: :controller do
  let!(:user) { create(:user) }
  let!(:billing_store) { create(:store, code: 'billing') }
  let!(:store1) { create(:store, url: 'api-production.bookme.plus') }
  let!(:store2) { create(:store, url: 'images.bookme.plus') }
  let!(:store3) { create(:store, url: 'static.bookme.plus') }
  let!(:default_store) { create(:store, default: true) }

  controller(Spree::Admin::BaseController) do
    def index
      render plain: 'Admin Dashboard'
    end

    def current_store
      @current_store ||= Rails.cache.fetch("current_store_#{request.host}", expires_in: 1.hour) do
        Spree::Store.where('url = ? OR url LIKE ?', request.host, "%#{request.host}%").first || Spree::Store.default
      end
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

  describe '#current_store' do
    before do
      Rails.cache.clear
      allow(Spree::Store).to receive(:default).and_return(default_store)
    end

    it 'returns the store matching the request host exactly' do
      allow(request).to receive(:host).and_return('api-production.bookme.plus')
      expect(controller.current_store).to eq(store1)
    end

    it 'returns the store matching the request host partially' do
      allow(request).to receive(:host).and_return('bookme.plus')
      expect(controller.current_store).to eq(store1)
    end

    it 'returns the default store if no match is found' do
      allow(request).to receive(:host).and_return('unknown.bookme.plus')
      expect(controller.current_store).to eq(default_store)
    end

    it 'memoizes the current store' do
      allow(request).to receive(:host).and_return('api-production.bookme.plus')
      expect(controller.current_store).to eq(store1)
      expect(controller.instance_variable_get(:@current_store)).to eq(store1)
    end

    it 'caches the store lookup' do
      allow(request).to receive(:host).and_return('api-production.bookme.plus')
      expect(Rails.cache).to receive(:fetch).with("current_store_api-production.bookme.plus", expires_in: 1.hour).and_call_original
      controller.current_store
    end
  end
end
