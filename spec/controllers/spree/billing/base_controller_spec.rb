require 'spec_helper'

RSpec.describe Spree::Billing::BaseController, type: :controller do
  context 'role authorization' do
    let(:vendor)     { create(:active_vendor)}
    let(:user)       { create(:user, vendors: [vendor])}

    controller do
      skip_before_action :load_resource

      def model_class; end

      def index
        head :ok
      end
    end

    before(:each) do
      allow(controller).to receive(:spree_current_user).and_return(user)
    end

    it 'authorize if user is admin' do
      user.spree_roles << create(:role, name: 'admin')

      allow(controller).to receive(:auth_entry).and_return('spree/billing/orders')
      allow(controller).to receive(:auth_action).and_return('index')

      get :index

      expect(controller.authorize?).to be true
    end

    it 'authorize index when user role has permission' do
      permission = create(:cm_permission, entry: 'spree/billing/orders', action: 'index')
      user.spree_roles << create(:role, permissions: [permission])

      allow(controller).to receive(:auth_entry).and_return('spree/billing/orders')
      allow(controller).to receive(:auth_action).and_return('index')

      get :index

      expect(controller.authorize?).to be true
    end

    it 'unauthorize index when user does not have permission' do
      allow(controller).to receive(:auth_entry).and_return('spree/billing/orders')
      allow(controller).to receive(:auth_action).and_return('index')

      get :index

      expect(controller.authorize?).to be false
      expect(response).to redirect_to billing_forbidden_url
    end
  end
end