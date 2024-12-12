module SpreeCmCommissioner
  module Admin
    module ProductsControllerDecorator
      def self.prepended(base)
        # spree update user sign_in_count
        base.around_action :set_writing_role, only: %i[index]
      end

      # Override
      def collection
        return @collection if @collection.present?

        params[:q] ||= {}
        params[:q][:deleted_at_null] ||= '1'
        params[:q][:s] ||= 'name asc'

        @collection = product_scope

        @collection = @collection.with_deleted if params[:q][:deleted_at_null] == '0'

        @search = @collection.ransack(params[:q].reject { |k, _v| k.to_s == 'deleted_at_null' })

        @collection = @search.result
                             .includes(*product_includes)
                             .page(params[:page])
                             .per(params[:per_page] || 10)

        @collection
      end

      # Override
      def product_includes
        [
          :vendor,
          :shipping_category,
          { master: :images },
          :variants
        ]
      end
    end
  end
end

unless Spree::Admin::ProductsController.ancestors.include?(SpreeCmCommissioner::Admin::ProductsControllerDecorator)
  Spree::Admin::ProductsController.prepend(SpreeCmCommissioner::Admin::ProductsControllerDecorator)
end
