module SpreeCmCommissioner
  module Imports
    class UpdateOrderService < BaseImportOrderService
      def import_orders
        content = fetch_content

        CSV.parse(content, headers: true).each.with_index(2) do |row, index|
          order_number = cleaned_value(row['order_number'])
          guest_id = cleaned_value(row['guest_id'])
          seat_number = cleaned_value(row['seat_number'])
          phone_number = cleaned_value(row['phone_number'])
          first_name = row['first_name']
          last_name = row['last_name']

          order = Spree::Order.find_by(number: order_number)

          unless order
            record_failure(index)
            next
          end

          guest = order.guests.find_by(seat_number: seat_number) || order.guests.find_by(id: guest_id)

          unless guest
            record_failure(index)
            next
          end

          unless guest.update(
            phone_number: phone_number,
            first_name: first_name,
            last_name: last_name
          )
            record_failure(index)
            next
          end
          recalculate_order(order)
        end
      end

      def recalculate_order(order)
        order.update_with_updater!
      end
    end
  end
end
