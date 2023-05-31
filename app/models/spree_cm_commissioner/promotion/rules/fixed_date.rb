module SpreeCmCommissioner
  module Promotion
    module Rules
      class FixedDate < Spree::PromotionRule
        preference :start_date, :string
        preference :length, :integer, default: 1

        MATCH_POLICIES = %w[any all].freeze
        preference :match_policy, :string, default: MATCH_POLICIES.first

        def applicable?(promotable)
          promotable.is_a?(Spree::Order) && promotable.line_items.any?(&:date_present?)
        end

        def eligible?(order, _options = {})
          case preferred_match_policy
          when 'any'
            order.line_items.any? { |item| line_item_eligible?(item) }
          when 'all'
            order.line_items.all? { |item| line_item_eligible?(item) }
          end
        end

        # later, we caculate promotion price only for eligible date
        def line_item_eligible?(line_item)
          return false unless line_item.date_present?

          line_item.date_range.any? do |date|
            date_eligible?(date)
          end
        end

        def date_eligible?(date)
          date.between?(start_rule_date, end_rule_date)
        end

        def start_rule_date
          preferred_start_date&.to_date
        end

        def end_rule_date
          return nil if start_rule_date.nil? || preferred_length.nil?

          start_rule_date + preferred_length.days - 1
        end

        # override
        def actionable?(line_item)
          line_item_eligible?(line_item)
        end
      end
    end
  end
end
