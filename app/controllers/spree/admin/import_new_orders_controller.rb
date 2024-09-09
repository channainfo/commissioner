module Spree
  module Admin
    class ImportNewOrdersController < BaseImportOrdersController
      # override
      def collection
        @collection ||= model_class.new_order.page(params[:page])
                                   .per(params[:per_page])
      end

      # override
      def collection_url
        admin_import_new_orders_url
      end

      # GET: /admin/orders/download_new_order_csv_template
      def download_new_order_csv_template
        respond_with do |format|
          format.csv do
            context = SpreeCmCommissioner::ImportCsvTemplateDownloader.call(import_type: 'new_order')
            send_file context.filepath, filename: context.filename, type: 'text/csv'
          end
        end
      end
    end
  end
end
