module SpreeCmCommissioner
  module Admin
    module OrdersControllerDecorator
      def self.prepended(base)
        # spree try to create an empty order in the #new action
        base.around_action :set_writing_role, only: %i[new]
      end
    end
  end
end

unless Spree::Admin::OrdersController.ancestors.include?(SpreeCmCommissioner::Admin::OrdersControllerDecorator)
  Spree::Admin::OrdersController.prepend(SpreeCmCommissioner::Admin::OrdersControllerDecorator)
end
