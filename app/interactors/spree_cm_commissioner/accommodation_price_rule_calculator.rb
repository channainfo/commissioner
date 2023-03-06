module SpreeCmCommissioner
  class AccommodationPriceRuleCalculator < BaseInteractor
    delegate :vendor, :from_date, :to_date, to: :context

    def call
      context.value = calculate_price_by_dates
    end

    private

    def calculate_price_by_dates
      vendor.active_pricing_rules.to_a.each do |pricing_rule|
        calculate_min_max_price(pricing_rule)
      end

      vendor.active_pricing_rules
    end

    def calculate_min_max_price(pricing_rule)
      calculate_min_max_price_by_day(pricing_rule)
      calculate_min_max_price_by_rule(pricing_rule) if pricing_rule.price_by_dates.present?
    end

    def calculate_min_max_price_by_day(pricing_rule)
      price_by_dates = []
      (from_date..to_date).each do |day|
        next unless pricing_rule.matching_rules(day.to_date)

        price_by_dates << { date: day.to_s,
                            min_price_by_rule: calculate_price(vendor.min_price, pricing_rule),
                            max_price_by_rule: calculate_price(vendor.max_price, pricing_rule)
                                        }
      end

      pricing_rule.price_by_dates = price_by_dates
    end

    def calculate_min_max_price_by_rule(pricing_rule)
      pricing_rule.min_price_by_rule = pricing_rule.price_by_dates.min_by { |h| h[:min_price_by_rule] }[:min_price_by_rule]
      pricing_rule.max_price_by_rule = pricing_rule.price_by_dates.max_by { |h| h[:max_price_by_rule] }[:max_price_by_rule]
    end

    def calculate_price(original_price, pricing_rule)
      original_price.method(pricing_rule.operator).call(pricing_rule.amount)
    end
  end
end
