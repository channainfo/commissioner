module SpreeCmCommissioner
  module Imports
    class BaseImportOrderService
      attr_reader :import_order_id, :fail_row_numbers

      def initialize(import_order_id:)
        @import_order_id = import_order_id
        @fail_row_numbers = []
      end

      def call
        update_import_status_when_start(:progress)
        import_orders
        save_fail_rows
        update_import_status_when_finish(:done)
      rescue StandardError => e
        update_import_status_when_finish(:failed)
        raise e
      end

      def save_fail_rows
        import_order.update!(preferred_fail_rows: @fail_row_numbers.join(', ')) unless @fail_row_numbers.empty?
      end

      def record_failure(row_number)
        @fail_row_numbers << row_number
      end

      def import_order
        @import_order ||= SpreeCmCommissioner::Imports::ImportOrder.find(import_order_id)
      end

      def update_import_status_when_start(status)
        import_order.update(status: status, started_at: Time.zone.now)
      end

      def update_import_status_when_finish(status)
        import_order.update(status: status, finished_at: Time.zone.now)
      end

      def fetch_content
        url = import_order.imported_file.url
        response = Faraday.get(url)

        raise "Failed to fetch content: #{response.status}" unless response.success?

        response.body
      end
    end
  end
end
