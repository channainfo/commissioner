module Spree
  module Admin
    class PricingActionsController < ResourceController
      skip_before_action :load_resource

      before_action :load_parent
      before_action :load_object, if: :member_action?

      def load_parent
        @product = Spree::Product.find_by!(slug: params[:product_id])
        @pricing_model = SpreeCmCommissioner::PricingModel.find(params[:pricing_model_id])
      end

      def load_object
        if new_actions.include?(action)
          @object = @pricing_model.pricing_actions.new(type: permitted_resource_params[:type])
        elsif params[:id]
          @object = @pricing_model.pricing_actions.find(params[:id])
        end
      end

      def create
        @object.attributes = permitted_resource_params

        if @object.save
          flash[:success] = flash_message_for(@object, :successfully_created)
        else
          flash[:error] = @object.errors.full_messages.to_sentence
        end

        redirect_to collection_url
      end

      # when calculator_type is being updated,
      # any previous calculator attributes should be removed.
      def update_params
        update_params = permitted_resource_params

        if @object.calculator_type.present? && permitted_resource_params[:calculator_type] != @object.calculator_type
          update_params = permitted_resource_params.except(:calculator_attributes)
        end

        update_params
      end

      def update
        if @object.update(update_params)
          flash[:success] = flash_message_for(@object, :successfully_updated)
        else
          flash[:error] = @object.errors.full_messages.to_sentence
        end

        redirect_to collection_url
      end

      def destroy
        if @object.destroy
          flash[:success] = flash_message_for(@object, :successfully_removed)
        else
          flash[:error] = @object.errors.full_messages.join(', ')
        end

        redirect_to collection_url
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
        SpreeCmCommissioner::PricingAction
      end

      # override
      def object_name
        'spree_cm_commissioner_pricing_action'
      end

      # override
      def collection_url(options = {})
        edit_admin_product_pricing_model_url(id: params[:pricing_model_id], **options)
      end

      # override
      def new_object_url(options = {})
        new_admin_product_pricing_action_url(options)
      end

      # override
      def edit_object_url(object, options = {})
        edit_admin_product_pricing_action_url(object, options)
      end

      # override
      def object_url(object, options = {})
        admin_product_pricing_action_url(object, options)
      end
    end
  end
end
