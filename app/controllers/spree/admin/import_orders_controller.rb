module Spree
  module Admin
    class ImportOrdersController < Spree::Admin::ResourceController
      # override
      def model_class
        SpreeCmCommissioner::Imports::ImportOrder
      end

      def index; end

      def create
        name = params[:spree_cm_commissioner_imports_import_order][:name]

        orders_json = params[:spree_cm_commissioner_imports_import_order][:orders_json]

        begin
          orders = JSON.parse(orders_json)
        rescue JSON::ParserError
          flash[:error] = 'Invalid JSON format for orders' # rubocop:disable Rails/I18nLocaleTexts
          redirect_to admin_import_orders_url and return
        end

        import_order = SpreeCmCommissioner::Imports::ImportOrder.new(name: name)

        if import_order.save
          SpreeCmCommissioner::ImportOrderJob.perform_later(import_order.id, spree_current_user, orders)
          flash[:success] = 'Importing guests...' # rubocop:disable Rails/I18nLocaleTexts
        else
          flash[:error] = 'Error importing guests' # rubocop:disable Rails/I18nLocaleTexts
        end

        redirect_to admin_import_orders_url
      end

      # GET: /admin/orders/download_order_csv_template
      def download_order_csv_template
        respond_with do |format|
          format.csv do
            context = SpreeCmCommissioner::ImportCsvTemplateDownloader.call
            send_file context.filepath, filename: context.filename, type: 'text/csv'
          end
        end
      end

      # override
      def collection
        @collection ||= model_class.all.page(params[:page])
                                   .per(params[:per_page])
      end

      # override
      def collection_url
        admin_import_orders_url
      end

      def permitted_resource_params
        params.require(object_name).permit(:name, :orders_json)
      end
    end
  end
end
