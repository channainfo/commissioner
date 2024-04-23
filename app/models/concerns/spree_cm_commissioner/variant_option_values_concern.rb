module SpreeCmCommissioner
  module VariantOptionValuesConcern
    extend ActiveSupport::Concern

    # TODO: extract value from this.
    def started_at_option_value
      option_value('started-at')
    end

    def reminder_option_value
      option_value('reminder')
    end

    def max_quantity_per_order_option_value
      @max_quantity_option_value ||= option_value('max-quantity-per-order')
    end

    # Some vendors restrict the quantity per order. This value is used to validate when user add item to cart.
    # if null, users can add unlimited quantity as long as items are in stock.
    def max_quantity_per_order
      max_quantity_per_order_option_value&.to_i
    end
  end
end
