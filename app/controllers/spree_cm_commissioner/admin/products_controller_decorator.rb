module SpreeCmCommissioner
  module Admin
    module ProductsControllerDecorator
      def self.prepended(base)
        # spree update user sign_in_count
        base.around_action :set_writing_role, only: %i[index]
      end
    end
  end
end

unless Spree::Admin::ProductsController.ancestors.include?(SpreeCmCommissioner::Admin::ProductsControllerDecorator)
  Spree::Admin::ProductsController.prepend(SpreeCmCommissioner::Admin::ProductsControllerDecorator)
end
