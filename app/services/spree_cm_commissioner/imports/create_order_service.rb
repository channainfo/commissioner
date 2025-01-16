module SpreeCmCommissioner
  module Imports
    class CreateOrderService < BaseImportOrderService
      attr_reader :import_by_user_id

      def initialize(import_order_id:, import_by_user_id:)
        super(import_order_id: import_order_id)
        @import_by_user_id = import_by_user_id
      end

      def import_orders
        content = fetch_content

        CSV.parse(content, headers: true).each.with_index(2) do |row, index|
          order_data = row.to_hash.symbolize_keys
          process_order(order_data, index)
        end
      end

      def process_order(order_data, index)
        ActiveRecord::Base.transaction do
          params = build_order_params(order_data)
          order = create_order(params, index)
          record_failure(index) if order && !complete_order(order)
        end
      rescue StandardError
        record_failure(index)
      end

      private

      def build_order_params(order_data)
        guest_attributes = order_data.slice(*SpreeCmCommissioner::Guest.csv_importable_columns)
        {
          channel: construct_channel(order_data[:order_channel]),
          email: order_data[:email],
          phone_number: order_data[:phone_number],
          line_items_attributes: [
            {
              quantity: order_data[:quantity].to_i,
              sku: order_data[:variant_sku],
              guests_attributes: Array.new(order_data[:quantity].to_i, guest_attributes)
            }
          ]
        }
      end

      def create_order(params, index)
        order = Spree::Core::Importer::Order.import(import_by, params)
        unless order
          record_failure(index)
          return nil
        end

        order
      end

      def complete_order(order)
        order.update(
          completed_at: Time.zone.now,
          state: 'complete',
          payment_total: order.total,
          payment_state: 'paid'
        )
      end

      def import_by
        @import_by ||= Spree::User.find(import_by_user_id)
      end

      def construct_channel(order_channel)
        "#{order_channel}-#{import_order.id}-#{import_order.slug}"
      end
    end
  end
end
