module Spree
  module Admin
    class BaseImportOrdersController < Spree::Admin::ResourceController
      def show
        @import ||= model_class.find(params[:id])
      end

      def create
        name = permitted_resource_params[:name]
        orders_json = permitted_resource_params[:orders_json]

        begin
          orders = JSON.parse(orders_json)
        rescue JSON::ParserError
          flash[:error] = 'Invalid JSON format for orders' # rubocop:disable Rails/I18nLocaleTexts
          redirect_to admin_import_new_orders_url and return
        end

        import_order = build_import_order(name)

        if import_order.save
          SpreeCmCommissioner::ImportOrderJob.perform_now(import_order.id, spree_current_user, orders, import_order.import_type)
          flash[:success] = 'Importing guests...' # rubocop:disable Rails/I18nLocaleTexts
        else
          flash[:error] = 'Error importing guests' # rubocop:disable Rails/I18nLocaleTexts
        end

        redirect_to collection_url
      end

      def object_name
        'spree_cm_commissioner_imports_import_order'
      end

      def build_import_order(name)
        model_class.new_order.new(name: name)
      end

      def model_class
        SpreeCmCommissioner::Imports::ImportOrder
      end

      def permitted_resource_params
        params.require(object_name).permit(:name, :orders_json)
      end
    end
  end
end
