module SpreeCmCommissioner
  module Imports
    class UpdateOrderService < BaseImportOrderService
      def import_orders
        content = fetch_content

        CSV.parse(content, headers: true).each.with_index(2) do |row, index|
          order_number = cleaned_value(row['order_number'])
          order = Spree::Order.find_by(number: order_number)

          unless order
            record_failure(index)
            next
          end

          guest_id = cleaned_value(row['guest_id'])
          seat_number = cleaned_value(row['seat_number'])
          guest = order.guests.find_by(seat_number: seat_number) || order.guests.find_by(id: guest_id)

          unless guest
            record_failure(index)
            next
          end

          guest_data = row.to_hash.symbolize_keys.slice(*SpreeCmCommissioner::Guest.csv_importable_columns)
          guest_data.compact_blank!

          if guest.update(guest_data)
            recalculate_order(order)
          else
            record_failure(index)
          end
        end
      end

      def recalculate_order(order)
        order.update_with_updater!
      end
    end
  end
end
