require 'spec_helper'

class FakeController < ApplicationController
  include SpreeCmCommissioner::Admin::RoleAuthorization

  # override
  def handle_unauthorization
    flash[:notice] = 'unauthorized'
  end
end

RSpec.describe FakeController, type: :controller do
  context 'role authorization' do
    controller do
      def index
        head :ok
      end
    end

    it 'authorize index when user role has permission' do
      permission = create(:cm_permission, entry: 'spree/admin/merchant/orders', action: 'index')
      role = create(:role, permissions: [permission])
      user = create(:user, spree_roles: [role])

      allow(controller).to receive(:auth_user).and_return(user)
      allow(controller).to receive(:auth_entry).and_return('spree/admin/merchant/orders')
      allow(controller).to receive(:auth_action).and_return('index')

      get :index

      expect(controller.authorize?).to be true
      expect(flash[:notice]).to eq nil
    end

    it 'unauthorize index when user does not have permission' do
      role = create(:role, permissions: [])
      user = create(:user, spree_roles: [role])

      allow(controller).to receive(:auth_user).and_return(user)
      allow(controller).to receive(:auth_entry).and_return('spree/admin/merchant/orders')
      allow(controller).to receive(:auth_action).and_return('index')

      get :index

      expect(controller.authorize?).to be false
      expect(flash[:notice]).to eq 'unauthorized'
    end
  end
end