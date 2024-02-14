module SpreeCmCommissioner
  module Promotion
    module Rules
      class GuestAgeGroup < Guest
        AGE_GROUPS = {
          baby: [0, 2],
          young: [3, 12],
          teenager: [13, 19],
          young_adults: [20, 29],
          adults: [30, 39],
          middle_aged: [40, 59],
          seniors: [60, 99]
        }.freeze

        preference :guest_age_group, :array, default: []

        # @overrided
        def eligible?(order, _options = {})
          return true if preferred_guest_age_group.empty?

          order.line_items.any? do |line_item|
            match_policy_condition?(line_item)
          end
        end

        # @overrided
        def guest_eligible?(guest, line_item)
          preferred_guest_age_group.each do |age_group|
            age_range = AGE_GROUPS[age_group.to_sym]
            min_age = age_range[0]
            max_age = age_range[1]

            return true if (guest.current_age >= min_age && guest.current_age <= max_age) && line_item.product.kyc?
          end

          false
        end
      end
    end
  end
end
