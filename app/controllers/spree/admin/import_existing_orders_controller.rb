module Spree
  module Admin
    class ImportExistingOrdersController < BaseImportOrdersController
      # override
      def collection
        @collection ||= model_class.existing_order.page(params[:page])
                                   .per(params[:per_page])
      end

      # override
      def collection_url
        admin_import_existing_orders_url
      end

      def build_import_order(name, imported_file)
        import_order = model_class.existing_order.new(name: name)
        import_order.imported_file.attach(imported_file) if imported_file.present?
        import_order
      end

      # GET: /admin/orders/download_existing_order_csv_template
      def download_existing_order_csv_template
        respond_with do |format|
          format.csv do
            context = SpreeCmCommissioner::ImportCsvTemplateDownloader.call(import_type: 'existing_order')
            send_file context.filepath, filename: context.filename, type: 'text/csv'
          end
        end
      end
    end
  end
end
