module SpreeCmCommissioner
  module Admin
    module PaymentsControllerDecorator
      def self.prepended(base)
        # spree call order.next on new which might set some data to database.
        base.around_action :set_writing_role, only: %i[new]
      end
    end
  end
end

unless Spree::Admin::PaymentsController.ancestors.include?(SpreeCmCommissioner::Admin::PaymentsControllerDecorator)
  Spree::Admin::PaymentsController.prepend(SpreeCmCommissioner::Admin::PaymentsControllerDecorator)
end
