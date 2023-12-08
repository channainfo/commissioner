module SpreeCmCommissioner
  module OrderUpdaterDecorator
    # override
    def update_item_total
      order.item_total = line_items.sum(&:amount)
      update_order_total
    end

    # override
    def update_adjustment_total
      super

      promotion_adjustment = adjustments.promotion.eligible.first

      return if promotion_adjustment.blank? # Check if the order has a promotion adjustment

      promotion = promotion_adjustment.source.promotion

      return unless promotion&.cap && order.adjustment_total.abs > promotion&.cap # Check if cap exist

      order.adjustment_total = order.promo_total = promotion.cap * -1

      update_order_total
    end
  end
end

unless Spree::OrderUpdater.included_modules.include?(SpreeCmCommissioner::OrderUpdaterDecorator)
  Spree::OrderUpdater.prepend SpreeCmCommissioner::OrderUpdaterDecorator
end
