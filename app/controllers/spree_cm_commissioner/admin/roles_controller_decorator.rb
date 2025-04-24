module SpreeCmCommissioner
  module Admin
    module RolesControllerDecorator
      def index
        @roles = Spree::Role.non_vendor.page(params[:page])
      end
    end
  end
end

unless Spree::Admin::RolesController.ancestors.include?(SpreeCmCommissioner::Admin::RolesControllerDecorator)
  Spree::Admin::RolesController.prepend(SpreeCmCommissioner::Admin::RolesControllerDecorator)
end
