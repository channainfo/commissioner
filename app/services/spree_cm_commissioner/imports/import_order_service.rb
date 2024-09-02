module SpreeCmCommissioner
  module Imports
    class ImportOrderService
      attr_reader :import_order_id, :import_by_user_id, :import_type

      def initialize(import_order_id:, import_by_user_id:, import_type:)
        @import_order_id = import_order_id
        @import_by_user_id = import_by_user_id
        @import_type = import_type
        @fail_order_numbers = []
      end

      def call
        update_import_status_when_start(:progress)
        import_orders
        save_fail_orders
        update_import_status_when_finish(:done)
      rescue StandardError => e
        update_import_status_when_finish(:failed)
        raise e
      end

      def save_fail_orders
        import_order.update!(preferred_fail_orders: @fail_order_numbers.join(', ')) unless @fail_order_numbers.empty?
      end

      def import_orders
        content = fetch_content

        CSV.parse(content, headers: true) do |row|
          order_data = row.to_hash.symbolize_keys
          case import_type
          when 'new_order'
            process_new_order(order_data)
          when 'existing_order'
            process_existing_order(order_data)
          else
            raise ArgumentError, "Unknown import_type: #{import_type}"
          end
        end
      end

      def process_existing_order(order_data)
        existing_order = Spree::Order.find_by(number: order_data[:order_number])

        if existing_order
          update_existing_order(existing_order, order_data)
        else
          record_failure(order_data[:order_number])
        end
      end

      def process_new_order(order_data)
        params = {
          channel: construct_channel(order_data[:order_channel]),
          email: order_data[:order_email],
          phone_number: order_data[:order_phone_number],
          line_items_attributes: [
            {
              quantity: 1,
              sku: order_data[:variant_sku],
              guests_attributes: [
                order_data.slice(*SpreeCmCommissioner::Guest.csv_importable_columns)
              ]
            }
          ]
        }

        order = Spree::Core::Importer::Order.import(import_by, params)
        update_order_state(order)
      end

      def update_existing_order(order, order_data)
        if order.update(
          channel: order_data[:order_channel],
          email: order_data[:order_email],
          phone_number: order_data[:order_phone_number],
          internal_note: order_data[:note]
        )
          recalculate_order(order)
          update_guest(order, order_data)
        else
          record_failure(order_data[:order_number])
        end
      end

      def recalculate_order(order)
        order.update_with_updater!
      end

      def update_guest(order, order_data)
        guest = order.line_items.first.guests.first
        if guest.present?
          guest_attributes = order_data.slice(*SpreeCmCommissioner::Guest.csv_importable_columns)
          guest.update!(guest_attributes)
        else
          record_failure(order_data[:order_number])
        end
      end

      def update_order_state(order)
        unless order.update!(
          completed_at: Time.zone.now,
          state: 'complete',
          payment_total: order.total,
          payment_state: 'paid'
        )
          record_failure(order.number)
        end
      end

      def record_failure(order_number)
        @fail_order_numbers << order_number
      end

      def import_order
        @import_order ||= SpreeCmCommissioner::Imports::ImportOrder.find(import_order_id)
      end

      def import_by
        @import_by ||= Spree::User.find(import_by_user_id)
      end

      def update_import_status_when_start(status)
        import_order.update(status: status, started_at: Time.zone.now)
      end

      def update_import_status_when_finish(status)
        import_order.update(status: status, finished_at: Time.zone.now)
      end

      def construct_channel(order_channel)
        "#{order_channel}-#{import_order.id}-#{import_order.slug}"
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
