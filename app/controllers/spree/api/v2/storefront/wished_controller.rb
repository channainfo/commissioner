module Spree
  module Api
    module V2
      module Storefront
        class WishedController < Spree::Api::V2::ResourceController
          def show
            variant_id = params[:id]
            wished_item = Spree::WishedItem.find_by(variant_id: variant_id)

            render json: wished_item
          end

          def model_class
            Spree::WishedItem
          end
        end
      end
    end
  end
end
