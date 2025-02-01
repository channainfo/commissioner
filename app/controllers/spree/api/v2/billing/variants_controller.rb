module Spree
  module Api
    module V2
      module Billing
        class VariantsController < Spree::Api::V2::BaseController
          def index
            @product = Spree::Product.where(subscribable: true).joins(:taxons).where(spree_taxons: { id: params[:taxonomy_id] }).first
            @variants = @product.variants
            render json: @variants, each_serializer: Spree::V2::Billing::VariantSerializer
          end

          def show
            @variant = Spree::Variant.find(params[:id])
            render json: @variant, serializer: Spree::V2::Billing::VariantSerializer
          end
        end
      end
    end
  end
end
