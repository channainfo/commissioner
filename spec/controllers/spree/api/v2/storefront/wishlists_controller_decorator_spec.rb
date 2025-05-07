require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::WishlistsControllerDecorator do
  let(:user) { create(:user) }
  let(:wishlist1) { create(:wishlist, user: user) }
  let(:wishlist2) { create(:wishlist, user: user) }
  let(:variant) { create(:cm_variant) }
  let(:wished_item) { create(:wished_item, wishlist: wishlist1, variant: variant) }
  let(:params) { {} }
  let(:controller) { Spree::Api::V2::Storefront::WishlistsController.new }

  before do
    allow_any_instance_of(Spree::Api::V2::Storefront::WishlistsController).to receive(:spree_current_user).and_return(user)
    allow(controller).to receive(:params).and_return(params)
    Spree::Api::V2::Storefront::WishlistsController.prepend(Spree::Api::V2::Storefront::WishlistsControllerDecorator)
  end

  describe '#collection' do
    subject { controller.send(:collection) }

    context 'when params[:variant_id] is present' do
      let(:params) { { variant_id: variant.id, page: 1, per_page: 10 } }

      it 'returns wishlists that include the specified variant' do
        wished_item
        expect(subject).to include(wishlist1)
        expect(subject).not_to include(wishlist2)
      end

      it 'paginates the results' do
        allow(Spree::Api::V2::Storefront::WishlistsControllerDecorator).to receive(:wishlists_scope).and_call_original

        wishlist_relation = Spree::Wishlist.all
        allow(wishlist_relation).to receive(:includes).with(:wished_items).and_return(wishlist_relation)
        allow(wishlist_relation).to receive(:where).with(wished_items: { variant_id: variant.id }).and_return(wishlist_relation)
        allow(wishlist_relation).to receive(:page).with(params[:page]).and_return(wishlist_relation)
        allow(wishlist_relation).to receive(:per).with(params[:per_page]).and_return(wishlist_relation)

        expect(Spree::Wishlist).to receive(:all).and_return(wishlist_relation)
        subject
      end
    end

    context 'when params[:variant_id] is not present' do
      let(:params) { { page: 1, per_page: 10 } }

      it 'returns all wishlists for the current user' do
        expect(subject).to include(wishlist1, wishlist2)
      end

      it 'orders wishlists by id in descending order' do
        allow(Spree::Api::V2::Storefront::WishlistsControllerDecorator).to receive(:wishlists_scope).and_call_original

        wishlist_relation = Spree::Wishlist.all
        allow(wishlist_relation).to receive(:order).with('id desc').and_return(wishlist_relation)
        allow(wishlist_relation).to receive(:page).with(params[:page]).and_return(wishlist_relation)
        allow(wishlist_relation).to receive(:per).with(params[:per_page]).and_return(wishlist_relation)

        expect(Spree::Wishlist).to receive(:all).and_return(wishlist_relation)
        subject
      end

      it 'paginates the results' do
        allow(Spree::Api::V2::Storefront::WishlistsControllerDecorator).to receive(:wishlists_scope).and_call_original

        wishlist_relation = Spree::Wishlist.all
        allow(wishlist_relation).to receive(:page).with(params[:page]).and_return(wishlist_relation)
        allow(wishlist_relation).to receive(:per).with(params[:per_page]).and_return(wishlist_relation)

        expect(Spree::Wishlist).to receive(:all).and_return(wishlist_relation)
        subject
      end
    end
  end

  describe '#collection_serializer' do
    it 'returns Spree::V2::Storefront::WishlistSerializer' do
      expect(controller.collection_serializer).to eq(Spree::V2::Storefront::WishlistSerializer)
    end
  end

  describe '#model_class' do
    it 'returns Spree::Wishlist' do
      expect(controller.model_class).to eq(Spree::Wishlist)
    end
  end
end
