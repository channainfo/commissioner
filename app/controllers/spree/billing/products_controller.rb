module Spree
  module Billing
    class ProductsController < Spree::Billing::BaseController
      before_action :load_data, except: :index

      def scope
        current_vendor.products
      end

      def collection
        return @collection if defined?(@collection)

        @search = scope.ransack(params[:q])
        @collection = @search.result.page(page).per(per_page)
      end

      def load_data
        @taxons = Taxon.order(:name)
        @option_types = OptionType.order(:name)
        @tax_categories = TaxCategory.order(:name)
        @shipping_categories = ShippingCategory.order(:name)
      end

      # overrided
      def find_resource
        scope.find_by(slug: params[:id])
      end

      # @overrided
      def collection_url(options = {})
        billing_products_url(options)
      end

      def location_after_save
        edit_billing_product_url(@product)
      end

      def model_class
        Spree::Product
      end

      def object_name
        'product'
      end
    end
  end
end
