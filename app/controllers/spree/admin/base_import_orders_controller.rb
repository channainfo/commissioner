module Spree
  module Admin
    class BaseImportOrdersController < Spree::Admin::ResourceController
      def show
        @import ||= model_class.find(params[:id])
      end

      def create
        name = permitted_resource_params[:name]
        orders_json = permitted_resource_params[:orders_json]
        imported_file = permitted_resource_params[:imported_file]

        begin
          orders = JSON.parse(orders_json)
        rescue JSON::ParserError
          flash[:error] = I18n.t('import_orders.invalid_json_format')
          redirect_to admin_import_new_orders_url and return
        end

        import_order = build_import_order(name, imported_file)

        if import_order.save
          SpreeCmCommissioner::ImportOrderJob.perform_later(import_order.id, spree_current_user, orders, import_order.import_type)
          flash[:success] = I18n.t('import_orders.success_message')
        else
          flash[:error] = I18n.t('import_orders.error_message')
        end

        redirect_to collection_url
      end

      def object_name
        'spree_cm_commissioner_imports_import_order'
      end

      def build_import_order(name, imported_file)
        import_order = model_class.new_order.new(name: name)
        import_order.imported_file.attach(imported_file) if imported_file.present?
        import_order
      end

      def model_class
        SpreeCmCommissioner::Imports::ImportOrder
      end

      def permitted_resource_params
        params.require(object_name).permit(:name, :orders_json).merge(imported_file: params[:imported_file])
      end

      # GET: /admin/orders/import_new_orders/:id/download
      # GET: /admin/orders/import_existing_orders/:id/download
      def download
        result = SpreeCmCommissioner::ImportedCsvDownloader.call(import_order_id: params[:id])

        if result.success?
          send_data result.file_data, filename: result.filename,
                                      type: result.content_type,
                                      disposition: 'attachment'
        else
          flash[:error] = result.error
          redirect_to collection_url
        end
      end
    end
  end
end
