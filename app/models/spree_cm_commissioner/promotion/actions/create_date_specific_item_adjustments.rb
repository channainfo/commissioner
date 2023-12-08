module SpreeCmCommissioner
  module Promotion
    module Actions
      class CreateDateSpecificItemAdjustments < Spree::PromotionAction
        include Spree::CalculatedAdjustments
        include Spree::AdjustmentSource

        has_many :adjustments, as: :source, class_name: 'Spree::Adjustment'
        before_validation -> { self.calculator ||= Spree::Calculator::PercentOnLineItem.new }

        def self.calculators
          spree_calculators.promotion_actions_create_item_adjustments
        end

        def perform(options = {})
          order = options[:order]
          promotion = options[:promotion]

          create_unique_adjustments(order, order.line_items) do |line_item|
            promotion.line_item_actionable?(order, line_item)
          end
        end

        def compute_amount(line_item)
          return 0 unless promotion.line_item_actionable?(line_item.order, line_item)

          amounts = [line_item.amount, compute_line_item_amount(line_item)]
          order = line_item.order

          # Prevent negative order totals
          amounts << (order.amount - order.adjustments.eligible.sum(:amount).abs) if order.adjustments.eligible.any?
          amounts.min * -1
        end

        # compute only on eligible date
        def compute_line_item_amount(line_item)
          line_item.date_range.filter_map do |date|
            if promotion.date_eligible?(date)
              line_item_per_unit = Struct.new(:amount, :currency, :quantity, :price)
                                         .new(line_item.amount_per_date_unit, line_item.currency,
                                              line_item.quantity, line_item.price
                                         )

              compute(line_item_per_unit)
            end
          end.sum
        end
      end
    end
  end
end
