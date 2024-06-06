module Spree
  module Admin
    class PricingModelsController < ResourceController
      skip_before_action :load_resource

      before_action :load_parent
      before_action :load_object, if: :member_action?

      def load_parent
        @product = Spree::Product.find_by!(slug: params[:product_id])

        return redirect_to admin_product_variants_url(@product) if @product.variants.empty?
        return redirect_to collection_url(variant_id: @product.variants.first&.id) if params[:variant_id].blank?
        return redirect_to collection_url(currency: Spree::Store.default.default_currency) if params[:currency].blank?

        @variant = Spree::Variant.find(params[:variant_id])
      end

      def load_object
        if new_actions.include?(action)
          @object = @variant.pricing_models.new
        elsif params[:id]
          @object = @variant.pricing_models.find(params[:id])
        end
      end

      def index
        @pricing_models = @variant.pricing_models

        respond_with(@pricing_models) do |format|
          format.html
          format.js { render partial: 'pricing_models' }
        end
      end

      def create
        @object.attributes = permitted_resource_params
        if @object.save
          flash[:success] = flash_message_for(@object, :successfully_created)
          redirect_to edit_object_url(@object)
        else
          render action: :new, status: :unprocessable_entity
        end
      end

      # override
      def default_url_options
        super.merge(
          product_id: params[:product_id],
          variant_id: params[:variant_id],
          currency: params[:currency]
        )
      end

      # override
      def model_class
        SpreeCmCommissioner::PricingModel
      end

      # override
      def object_name
        'spree_cm_commissioner_pricing_model'
      end

      # override
      def collection_url(options = {})
        admin_product_pricing_models_url(options)
      end

      # override
      def new_object_url(options = {})
        new_admin_product_pricing_model_url(options)
      end

      # override
      def edit_object_url(object, options = {})
        edit_admin_product_pricing_model_url(@product, object, options)
      end

      # override
      def object_url(object, options = {})
        admin_product_pricing_model_url(@product, object, options)
      end
    end
  end
end
