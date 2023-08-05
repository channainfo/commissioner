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
        @selected_option_type_ids = Spree::OptionType.where(name: %w[month payment-option due-date]).ids
      end

      # overrided
      def find_resource
        scope.find_by(slug: params[:id])
      end

      def location_after_save
        edit_billing_product_url(@product)
      end

      def variant_stock_includes
        [:images, { stock_items: :stock_location, option_values: :option_type }]
      end

      def stock
        @variants = @product.variants.includes(*variant_stock_includes)
        @variants = [@product.master] if @variants.empty?
        @stock_locations = StockLocation.accessible_by(current_ability)
        return unless @stock_locations.empty?

        flash[:error] = Spree.t(:stock_management_requires_a_stock_location)
        redirect_to spree.admin_stock_locations_path
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
