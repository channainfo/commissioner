module SpreeCmCommissioner
  module Accommodations
    class Find
      attr_reader :from_date, :to_date, :state_id, :number_of_guests

      def initialize(from_date:, to_date:, state_id:, number_of_adults:, number_of_kids:)
        @from_date = from_date
        @to_date = to_date
        @state_id = state_id
        @number_of_guests = number_of_adults.to_i + number_of_kids.to_i
      end

      def execute
        scope
          .where(default_state_id: state_id)
          .where(inventory_items: { inventory_date: stay_dates })
          .where('CAST(spree_variants.public_metadata->\'cm_options\'->>\'number-of-adults\' AS INTEGER) +
                  CAST(spree_variants.public_metadata->\'cm_options\'->>\'number-of-kids\' AS INTEGER) >= ?', number_of_guests
          )
          .where('inventory_items.quantity_available > 0')
          .distinct
      end

      private

      def scope
        Spree::Vendor
          .joins(variants: :inventory_items)
          .where(primary_product_type: :accommodation, state: :active)
      end

      def stay_dates
        from_date..to_date
      end
    end
  end
end
