module Spree
  module Api
    module V2
      module Storefront
        class WishedController < ApplicationController
          def show
            variant_id = params[:id]
            variant = Spree::Variant.find_by(id: variant_id)
            wished_item = resource.wished_items.find_or_initialize_by(variant_id: variant.id)

            render json: wished_item
          end
        end
      end
    end
  end
end
