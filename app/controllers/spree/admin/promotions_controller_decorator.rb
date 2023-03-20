module Spree
  module Admin
    module PromotionsControllerDecorator
      protected

      # @overrided
      def load_data
        @actions = fetch_actions
        @calculators = Rails.application.config.spree.calculators.promotion_actions_create_adjustments
        @promotion_categories = Spree::PromotionCategory.order(:name)
      end

      def fetch_actions
        return @object.class::ACTIONS if member_action?

        Rails.application.config.spree.promotions.actions
      end
    end
  end
end

Spree::Admin::PromotionsController.prepend(Spree::Admin::PromotionsControllerDecorator)
