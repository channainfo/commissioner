module SpreeCmCommissioner
  class AccommodationPriceRule < BaseInteractor
    delegate :vendor, :from_date, :to_date, to: :context

    def call
      context.value = calculate_prices
    end

    private

    def calculate_prices
      vendor.active_pricing_rules.to_a.each do |pricing_rule|
        pricing_rule.price_by_dates = []

        calculate_min_max_price_by_day(pricing_rule)
        calculate_min_max_price_by_rule(pricing_rule) if pricing_rule.price_by_dates.present?
      end

      vendor.active_pricing_rules
    end

    def calculate_min_max_price_by_day(pricing_rule)
      (from_date..to_date).each do |day|
        next unless SpreeCmCommissioner::PriceRule.call(rule: pricing_rule, day: day.to_date).matched

        pricing_rule.price_by_dates << { date: day.to_s, min_price_by_rule: min_price_by_rule(pricing_rule),
                                         max_price_by_rule: max_price_by_rule(pricing_rule)
}
      end
    end

    def calculate_min_max_price_by_rule(pricing_rule)
      pricing_rule.min_price_by_rule = pricing_rule.price_by_dates.min_by { |h| h[:min_price_by_rule] }[:min_price_by_rule]
      pricing_rule.max_price_by_rule = pricing_rule.price_by_dates.max_by { |h| h[:max_price_by_rule] }[:max_price_by_rule]
    end

    def min_price_by_rule(pricing_rule)
      vendor.min_price.method(pricing_rule.operator).call(pricing_rule.amount)
    end

    def max_price_by_rule(pricing_rule)
      vendor.max_price.method(pricing_rule.operator).call(pricing_rule.amount)
    end
  end
end
