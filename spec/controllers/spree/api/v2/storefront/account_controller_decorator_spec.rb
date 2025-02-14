require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::AccountControllerDecorator do
  describe '.resource_serializer' do
    let(:user) { create(:user) }
    let(:guest_user) { create(:cm_guest_user) }
    let(:controller) { Spree::Api::V2::Storefront::AccountController.new }

    context 'is a guest user' do
      before do
        allow_any_instance_of(Spree::Api::V2::Storefront::AccountController).to receive(:spree_current_user).and_return(guest_user)
      end

      it 'returns Spree::V2::Storefront::GuestUserSerializer' do
        expect(controller.send(:resource_serializer)).to eq(Spree::V2::Storefront::GuestUserSerializer)
      end
    end

    context 'is not a guest user' do
      before do
        allow_any_instance_of(Spree::Api::V2::Storefront::AccountController).to receive(:spree_current_user).and_return(user)
      end

      it 'returns Spree::V2::Storefront::UserSerializer' do
        expect(controller.send(:resource_serializer)).to eq(Spree::V2::Storefront::UserSerializer)
      end
    end
  end
end
