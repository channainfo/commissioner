module Spree
  module Api
    module V2
      module Storefront
        module WishlistsControllerDecorator
          def collection
            wishlists = spree_current_user.wishlists.order(id: :desc)
                                          .page(params[:page])
                                          .per(params[:per_page])

            if params[:variant_id]
              # Fetch wishlists that include the specified variant
              wishlists.joins(:wished_items)
                       .where(wished_items: { variant_id: params[:variant_id] })
            else
              # Fetch all wishlists for the current user, order by id desc, and paginate
              wishlists
            end
          end

          def collection_serializer
            Spree::V2::Storefront::WishlistSerializer
          end

          def model_class
            Spree::Wishlist
          end
        end
      end
    end
  end
end

Spree::Api::V2::Storefront::WishlistsController.prepend(Spree::Api::V2::Storefront::WishlistsControllerDecorator)
