module SpreeCmCommissioner
  class PriceRule < BaseInteractor
    delegate :rule, :day, to: :context

    def call
      matching_rules
    end

    private

    def matching_rules
      date_rule = rule.date_rule
      start_rule_date = Date.parse(date_rule['value'])
      end_rule_date = start_rule_date + date_rule.length - 1
      context.matched = date_rule['type'] == 'fixed_date' && day.between?(start_rule_date, end_rule_date)
    end
  end
end
