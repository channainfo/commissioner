module SpreeCmCommissioner
  module Imports
    class ImportOrderService
      attr_reader :import_order_id, :orders, :import_by

      def initialize(import_order_id:, orders:, import_by:)
        @import_order_id = import_order_id
        @orders = orders
        @import_by = import_by
      end

      def call
        update_import_status_when_start(:progress)

        import_orders(orders)

        update_import_status_when_finish(:done)
      rescue StandardError => e
        update_import_status_when_finish(:failed)
        raise e
      end

      def import_orders(orders)
        ActiveRecord::Base.transaction do
          orders.map do |order|
            create_order(order)
          end
        end
      end

      def create_order(order)
        order_json = order.deep_symbolize_keys

        params = {
          channel: order_json[:order_channel],
          email: order_json[:order_email],
          phone_number: order_json[:order_phone_number],
          line_items_attributes: [
            {
              quantity: 1,
              sku: order_json[:variant_sku],
              guests_attributes: [
                order_json.slice(*SpreeCmCommissioner::Guest.csv_importable_columns)
              ]
            }
          ]
        }

        order = Spree::Core::Importer::Order.import(import_by, params)

        update_order_state(order)
      end

      def update_order_state(order)
        order.update!(
          completed_at: Time.zone.now,
          state: 'complete',
          payment_total: order.total,
          payment_state: 'paid'
        )
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
    end
  end
end
