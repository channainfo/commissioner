module Spree
  module Admin
    module BaseControllerDecorator
      def self.prepended(base)
        base.include SpreeCmCommissioner::Admin::RoleAuthorization
      end
    end
  end
end

Spree::Admin::BaseController.prepend(Spree::Admin::BaseControllerDecorator)
