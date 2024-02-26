module Spree
  module Admin
    class WishedItemControllerDecorator < Spree::Admin::ResourceController
      def create
        wished_product = wishlist.wished_products.find_or_initialize_by(variant_id: params[:wished_product][:variant_id])
        wished_product.assign_attributes(wished_product_attributes)
        flash.notice = if wished_product.save
                         'Successfully created'
                       else
                         'Failed to create'
                       end
        redirect_back fallback_location: root_url
      end

      def destroy
        @wished_product = Spree::WishedProduct.find(params[:id])
        @wished_product.destroy
        flash.notice = 'Removed from wishlist'
        redirect_back fallback_location: root_url
      end

      private

      def wished_product_attributes
        params.require(:wished_product).permit(:remark, :quantity)
      end

      def wishlist
        @wishlist ||= spree_current_user.wishlists.find_or_create_by(is_default: true) do |wishlist|
          wishlist.name = 'default'
        end
      end
    end
  end
end

Spree::Api::V2::Storefront::WishlistsController.prepend(SpreeCmCommissioner::Api::V2::Storefront::WishedItemControllerDecorator)
