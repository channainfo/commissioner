module SpreeCmCommissioner
  module Promotion
    module Rules
      class Guest < Spree::PromotionRule
        MATCH_POLICIES = %w[any all none].freeze
        preference :match_policy, :string, default: MATCH_POLICIES.first

        # @overrided
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        # @overrided
        def actionable?(line_item)
          match_policy_condition?(line_item)
        end

        def match_policy_condition?(line_item)
          case preferred_match_policy
          when 'all'
            line_item.guests.all? { |guest| guest_eligible?(guest, line_item) }
          when 'any'
            line_item.guests.any? { |guest| guest_eligible?(guest, line_item) }
          when 'none'
            line_item.guests.none? { |guest| guest_eligible?(guest, line_item) }
          else
            false
          end
        end

        def guest_eligible?(_guest, _line_item)
          raise 'guest_eligible? should be implemented in a sub-class of SpreeCmCommissioner::Promotion::Rules::Guests'
        end
      end
    end
  end
end
