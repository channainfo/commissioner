module SpreeCmCommissioner
  module Promotion
    module Rules
      class Date < Spree::PromotionRule
        self.abstract_class = true

        MATCH_POLICIES = %w[any all].freeze
        preference :match_policy, :string, default: MATCH_POLICIES.first

        # DATE_MATCH_POLICIES = %w[any all].freeze
        # preference :date_match_policy, :string, default: DATE_MATCH_POLICIES.first

        # override
        def applicable?(promotable)
          promotable.is_a?(Spree::Order) && promotable.line_items.any?(&:date_present?)
        end

        # override
        # use to check whether promotion is eligible to this rule
        def eligible?(order, _options = {})
          case preferred_match_policy
          when 'any'
            order.line_items.any? { |item| line_item_eligible?(item) }
          when 'all'
            order.line_items.all? { |item| line_item_eligible?(item) }
          end
        end

        # line items is considered eligible when any of date range is eligible.
        # then, we use action to apply promotion only on eligible dates.
        def line_item_eligible?(line_item)
          return false unless line_item.date_present?

          line_item.date_range.any? { |date| date_eligible?(date) }
        end

        # override
        def actionable?(line_item)
          line_item_eligible?(line_item)
        end

        def date_eligible?(_date)
          raise 'date_eligible? should be implemented in a sub-class of SpreeCmCommissioner::Promotion::Rules::Date'
        end
      end
    end
  end
end
