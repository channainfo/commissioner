module SpreeCmCommissioner
  module Admin
    module DashboardControllerDecorator
      def self.prepended(base)
        # spree try to update user on the GET show
        base.around_action :set_writing_role, only: %i[show]
      end
    end
  end
end

unless Spree::Admin::DashboardController.ancestors.include?(SpreeCmCommissioner::Admin::DashboardControllerDecorator)
  Spree::Admin::DashboardController.prepend(SpreeCmCommissioner::Admin::DashboardControllerDecorator)
end
