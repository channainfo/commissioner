module SpreeCmCommissioner
  module Promotion
    module Rules
      class GuestOccupations < Spree::PromotionRule
        has_many :guest_occupation_promotion_rules,
                 class_name: 'SpreeCmCommissioner::GuestOccupationPromotionRule',
                 foreign_key: :promotion_rule_id,
                 dependent: :destroy

        has_many :guest_occupations, through: :guest_occupation_promotion_rules, source: :occupation, class_name: 'Spree::Taxon'

        def eligible_guest_occupations
          guest_occupations
        end

        MATCH_POLICIES = %w[any all none].freeze
        preference :match_policy, :string, default: MATCH_POLICIES.first

        # @overrided
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        # @overrided
        def eligible?(order, _options = {})
          return true if eligible_guest_occupations.empty?

          order.line_items.any? do |line_item|
            match_policy_condition?(line_item)
          end
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

        def guest_eligible?(guest, line_item)
          eligible_guest_occupations.include?(guest.occupation) && line_item.product.kyc?
        end

        def guest_occupation_ids_string
          guest_occupation_ids.join(',')
        end

        def guest_occupation_ids_string=(value)
          self.guest_occupation_ids = value
        end
      end
    end
  end
end
