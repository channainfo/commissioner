module SpreeCmCommissioner
  module VariantOptionValuesConcern
    extend ActiveSupport::Concern

    # TODO: extract value from this.
    def started_at_option_value
      @started_at_option_value ||= option_value('started-at')
    end

    def reminder_option_value
      @reminder_option_value ||= option_value('reminder')
    end

    def delivery_option_option_value
      @delivery_option_option_value ||= option_value('delivery-option')
    end

    def max_quantity_per_order_option_value
      @max_quantity_option_value ||= option_value('max-quantity-per-order')
    end

    # Some vendors restrict the quantity per order. This value is used to validate when user add item to cart.
    # if null, users can add unlimited quantity as long as items are in stock.
    def max_quantity_per_order
      max_quantity_per_order_option_value&.to_i
    end

    def started_at
      started_at_option_value
    end

    def reminder
      reminder_option_value
    end

    def delivery_option
      delivery_option_option_value
    end
  end
end
