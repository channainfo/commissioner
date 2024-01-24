module SpreeCmCommissioner
  module Promotion
    module Rules
      class GuestAges < Guest
        preference :guest_ages, :array, default: []
        before_save :convert_guest_ages_to_int_list

        # @overrided
        def eligible?(order, _options = {})
          return true if preferred_guest_ages.empty?

          order.line_items.any? do |line_item|
            match_policy_condition?(line_item)
          end
        end

        # @overrided
        def guest_eligible?(guest, line_item)
          preferred_guest_ages.include?(guest.current_age) && line_item.product.kyc?
        end

        private

        def convert_guest_ages_to_int_list
          self.preferred_guest_ages = preferred_guest_ages.map(&:to_i)
        end
      end
    end
  end
end
