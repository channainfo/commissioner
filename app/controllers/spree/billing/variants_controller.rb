module Spree
  module Billing
    class VariantsController < Spree::Billing::BaseController
      belongs_to 'spree/product', find_by: :slug
      before_action :load_data

      def collection
        return @collection if @collection.present?

        params[:q] ||= {}
        @deleted = params[:q].delete(:deleted_at_null) || '0'
        @collection = super
        @collection = @collection.deleted if @deleted == '1'
        # @search needs to be defined as this is passed to search_link
        @search = @collection.ransack(params[:q])
        @collection = @search.result
                             .page(params[:page])
                             .per(params[:per_page] || Spree::Backend::Config[:variants_per_page])
      end
z 
      private

      def load_data
        @tax_categories = TaxCategory.order(:name)
      end

      def model_class
        Spree::Variant
      end

      def object_name
        'variant'
      end
    end
  end
end
