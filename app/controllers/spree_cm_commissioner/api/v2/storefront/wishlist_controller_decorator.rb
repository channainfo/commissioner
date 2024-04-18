module SpreeCmCommissioner
  module Api
    module V2
      module Storefront
        module WishlistControllerDecorator
          def update
            authorize! :update, resource

            variant_id = Spree::Variant.find(params[:variant_id])
            wished_item = resource.wished_items.find_or_initialize_by(variant_id: variant_id)

            if wished_item.persisted?
              wished_item.destroy
              render json: { message: 'Item marked as wished successfully' }, status: :ok
            else
              wished_item.save
              render json: { message: 'Item unmarked as wished successfully' }, status: :created
            end
          end
        end
      end
    end
  end
end

unless Spree::Api::V2::Storefront::WishlistsController.ancestors.include?(SpreeCmCommissioner::Api::V2::Storefront::WishlistControllerDecorator)
  Spree::Api::V2::Storefront::WishlistsController.prepend(SpreeCmCommissioner::Api::V2::Storefront::WishlistControllerDecorator)
end
