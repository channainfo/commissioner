# rubocop:disable Metrics/AbcSize

module SpreeCmCommissioner
  class PromotionCalculatorSummarizer < BaseInteractor
    delegate :calculator, :original_amount, :original_amount_currency, :match_all, to: :context

    def call
      calculate
      load_prices
    end

    def calculate
      case calculator
      when Spree::Calculator::FlatPercentItemTotal
        context.advertised_text = advertised_flat_percent_item_total_text
        context.computed_amount = calculator.compute(object)
      when Spree::Calculator::FlatRate
        context.advertised_text = advertised_flat_rate_text
        context.computed_amount = calculator.compute(object)
      when Spree::Calculator::FlexiRate
        context.advertised_text = advertised_flexi_rate_text
        context.computed_amount = calculator.compute(object)
      when Spree::Calculator::TieredPercent
        context.advertised_text = advertised_tiered_percent_text
        context.computed_amount = calculator.compute(object)
      when Spree::Calculator::TieredFlatRate
        context.advertised_text = advertised_tiered_flat_rate_text
        context.computed_amount = calculator.compute(object)
      when Spree::Calculator::PercentOnLineItem
        context.advertised_text = advertised_percent_on_line_item_text
        context.computed_amount = calculator.compute(object)
      else
        context.computed_amount = nil
        context.advertised_text = nil
      end
    end

    def load_prices
      if context.computed_amount.present?
        context.price = original_amount - context.computed_amount
        context.compare_at_price = original_amount
      else
        context.price = original_amount
        context.compare_at_price = nil
      end
    end

    def currency
      if calculator.respond_to?(:preferred_currency)
        calculator.preferred_currency
      else
        original_amount_currency
      end
    end

    private

    def advertised_flat_percent_item_total_text
      return nil if calculator.preferred_flat_percent.negative?

      t('percent_off', percent: calculator.preferred_flat_percent.round)
    end

    def advertised_flat_rate_text
      return nil if calculator.preferred_amount.negative?

      t('amount_off', amount: display_amount(calculator.preferred_amount))
    end

    def advertised_flexi_rate_text
      amount = [calculator.amount_off_on_other_item, calculator.preferred_first_item].max
      t('amount_off_on_eligible_items', amount: display_amount(amount))
    end

    def advertised_tiered_percent_text
      minimum_amount, percent = calculator.preferred_tiers.sort.reverse.detect { |b, _| object.amount >= b }
      t('percent_off_on_minimum_amount', percent: percent.round, minimum_amount: display_amount(minimum_amount))
    end

    def advertised_tiered_flat_rate_text
      minimum_amount, amount = preferred_tiers.sort.reverse.detect { |b, _| object.amount >= b }
      t('amount_off_on_minimum_amount', amount: display_amount(amount), minimum_amount: display_amount(minimum_amount))
    end

    def advertised_percent_on_line_item_text
      t('percent_off', { percent: calculator.preferred_percent.round })
    end

    def display_amount(amount)
      Spree::Money.new(amount, currency: currency).to_s
    end

    def object
      original_amount = context.original_amount
      original_amount_currency = context.original_amount_currency

      context.object ||= Object.new.tap do |obj|
        obj.define_singleton_method(:amount) { original_amount }
        obj.define_singleton_method(:currency) { original_amount_currency }
      end
    end

    def t(key, args = {})
      msg = I18n.t("spree_cm_commissioner.advertised_caculator.#{key}", **args)
      msg = I18n.t('spree_cm_commissioner.up_to', suffix: msg) unless match_all

      msg
    end
  end
end

# rubocop:enable Metrics/AbcSize
