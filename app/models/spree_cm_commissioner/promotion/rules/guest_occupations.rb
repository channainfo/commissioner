module SpreeCmCommissioner
  module Promotion
    module Rules
      class GuestOccupations < Guest
        has_many :guest_occupation_promotion_rules,
                 class_name: 'SpreeCmCommissioner::GuestOccupationPromotionRule',
                 foreign_key: :promotion_rule_id,
                 dependent: :destroy

        has_many :guest_occupations, through: :guest_occupation_promotion_rules, source: :occupation, class_name: 'Spree::Taxon'

        def eligible_guest_occupations
          guest_occupations
        end

        # @overrided
        def eligible?(order, _options = {})
          return true if eligible_guest_occupations.empty?

          order.line_items.any? do |line_item|
            match_policy_condition?(line_item)
          end
        end

        # @overrided
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
