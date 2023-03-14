module SpreeCmCommissioner
  class PricingModel
    module Rules
      class FixedDate < SpreeCmCommissioner::PricingModelRule
        preference :start_date, :string
        preference :length, :integer, default: 1

        MATCH_POLICIES = %w[any none].freeze
        preference :match_policy, :string, default: MATCH_POLICIES.first

        def applicable?(modelable)
          modelable.is_a?(SpreeCmCommissioner::ListingPrice)
        end

        def eligible?(modelable, _options = {})
          case preferred_match_policy
          when 'any'
            date_eligible?(modelable.date)
          else
            !date_eligible?(modelable.date)
          end
        end

        def date_eligible?(date)
          start_rule_date = preferred_start_date.to_date
          end_rule_date = start_rule_date + preferred_length.days - 1
          date.to_date.between?(start_rule_date, end_rule_date)
        end
      end
    end
  end
end
