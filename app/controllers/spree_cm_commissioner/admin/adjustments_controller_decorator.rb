module SpreeCmCommissioner
  module Admin
    module AdjustmentsControllerDecorator
      # override
      def update_totals
        super

        return unless action == :create || action == :update

        # recorded when create/update.
        @object.payable = spree_current_user
        @object.save!
      end
    end
  end
end

unless Spree::Admin::AdjustmentsController.ancestors.include?(SpreeCmCommissioner::Admin::AdjustmentsControllerDecorator)
  Spree::Admin::AdjustmentsController.prepend(SpreeCmCommissioner::Admin::AdjustmentsControllerDecorator)
end
