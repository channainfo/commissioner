module SpreeCmCommissioner
  module Promotion
    module Rules
      class Vendors < Spree::PromotionRule
        has_many :vendor_promotion_rules,
                 class_name: 'SpreeCmCommissioner::VendorPromotionRule',
                 foreign_key: :promotion_rule_id,
                 dependent: :destroy

        has_many :vendors, through: :vendor_promotion_rules, class_name: 'Spree::Vendor'

        alias eligible_vendors vendors

        MATCH_POLICIES = %w[any all none].freeze
        preference :match_policy, :string, default: MATCH_POLICIES.first

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          return true if eligible_vendors.empty?

          case preferred_match_policy
          when 'all'
            order.line_items.all? { |line_item| eligible_vendors.include?(line_item.vendor) }
          when 'any'
            order.line_items.any? { |line_item| eligible_vendors.include?(line_item.vendor) }
          when 'none'
            order.line_items.none? { |line_item| eligible_vendors.include?(line_item.vendor) }
          else
            false
          end
        end

        def actionable?(line_item)
          case preferred_match_policy
          when 'any', 'all'
            vendor_ids.include? line_item.vendor_id
          when 'none'
            vendor_ids.exclude? line_item.vendor_id
          else
            false
          end
        end

        def vendor_ids_string
          vendor_ids.join(',')
        end

        def vendor_ids_string=(value)
          self.vendor_ids = value
        end
      end
    end
  end
end
