module Spree
  module Admin
    class ProductCompletionStepsController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      before_action :load_step_types, if: :member_action?

      def load_step_types
        @step_types = [
          'SpreeCmCommissioner::ProductCompletionSteps::ChatraceTelegram'
        ]
      end

      # override
      def permitted_resource_params
        key = ActiveModel::Naming.param_key(@object)
        permit_keys = params.require(key).keys

        params.require(key).permit(permit_keys)
      end

      # @overrided
      def collection
        parent.product_completion_steps
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::ProductCompletionStep
      end

      # @overrided
      def new_object_url(options = {})
        new_admin_product_product_completion_step_url(options)
      end

      # @overrided
      def edit_object_url(object, options = {})
        edit_admin_product_product_completion_step_url(parent, object, options)
      end

      # @overrided
      def object_url(object, options = {})
        admin_product_product_completion_step_url(parent, object, options)
      end

      # @overrided
      def collection_url(options = {})
        admin_product_product_completion_steps_url(options)
      end

      # override
      def location_after_save
        edit_object_url(@object)
      end
    end
  end
end
