module SpreeCmCommissioner
  module Accommodations
    class FindVariant
      attr_reader :vendor_id, :from_date, :to_date, :number_of_guests

      def initialize(vendor_id:, from_date:, to_date:, number_of_adults:, number_of_kids:)
        @vendor_id = vendor_id
        @from_date = from_date
        @to_date = to_date
        @number_of_guests = number_of_adults.to_i + number_of_kids.to_i
      end

      def execute
        Spree::Variant
          .joins(:inventory_items)
          .where(vendor_id: vendor_id)
          .where(inventory_items: { inventory_date: stay_dates })
          .where('CAST(public_metadata->\'cm_options\'->>\'number-of-adults\' AS INTEGER) +
                  CAST(public_metadata->\'cm_options\'->>\'number-of-kids\' AS INTEGER) >= ?', number_of_guests
          )
          .where('inventory_items.quantity_available > 0')
          .distinct
      end

      private

      def stay_dates
        from_date..to_date
      end
    end
  end
end
