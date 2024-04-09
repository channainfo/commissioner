module SpreeCmCommissioner
  module Admin
    module ProductsControllerDecorator
      include SpreeCmCommissioner::Admin::ProductTypeHelper

      def self.prepended(base)
        # spree update user sign_in_count
        base.around_action :set_writing_role, only: %i[index]
      end

      # overrided
      def permitted_resource_params
        product_type_value = calculate_product_type_value(params[:product])

        params.require(:product).permit(:name, :sku, :prototype_id, :price, :shipping_category_id,
                                        :vendor_id, :subscribable, :need_confirmation
        ).merge(product_type: product_type_value)
      end
    end
  end
end

unless Spree::Admin::ProductsController.ancestors.include?(SpreeCmCommissioner::Admin::ProductsControllerDecorator)
  Spree::Admin::ProductsController.prepend(SpreeCmCommissioner::Admin::ProductsControllerDecorator)
end
