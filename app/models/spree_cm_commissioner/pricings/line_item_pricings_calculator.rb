# Calculate the amount for line items by combining eligible rates and pricing models.
module SpreeCmCommissioner
  module Pricings
    class LineItemPricingsCalculator
      attr_reader :line_item, :applied_pricing_rates, :applied_pricing_models

      def initialize(line_item:)
        @line_item = line_item
      end

      def call
        clear_previous_pricings
        apply_pricings
        persist_totals
      end

      def clear_previous_pricings
        line_item.applied_pricing_rates.delete_all
        line_item.applied_pricing_models.delete_all
      end

      # date_range could be number of nights, or days or hours depending on usecases
      # For example:
      # - accomodation uses number of nights.
      # - appointment uses number of hours, etc.
      def apply_pricings
        if line_item.reservation?
          line_item.date_range.map.with_index do |date, date_index|
            date_unit_options = { date: date, date_index: date_index, date_range: line_item.date_range }

            line_item.applied_pricing_rates += build_pricing_rates(quantity: line_item.quantity, date_unit_options: date_unit_options)
            line_item.applied_pricing_models += build_pricing_models(quantity: line_item.quantity, date_unit_options: date_unit_options)
          end
        else
          line_item.applied_pricing_rates += build_pricing_rates(quantity: line_item.quantity)
          line_item.applied_pricing_models += build_pricing_models(quantity: line_item.quantity)
        end
      end

      def persist_totals
        line_item.pricing_rates_amount = line_item.applied_pricing_rates.map(&:amount).sum || 0
        line_item.pricing_models_amount = line_item.applied_pricing_models.map(&:amount).sum || 0
        line_item.pricing_subtotal = line_item.pricing_rates_amount + line_item.pricing_models_amount
        line_item.save!
      end

      def build_pricing_rates(quantity:, date_unit_options: {})
        VariantPricingRatesComputer.new(
          variant: line_item.variant,
          quantity: quantity,
          booking_date: booking_date,
          guest_options: line_item.guest_options,
          date_unit_options: date_unit_options
        ).call
      end

      def build_pricing_models(quantity:, date_unit_options: {})
        VariantPricingModelsComputer.new(
          variant: line_item.variant,
          quantity: quantity,
          booking_date: booking_date,
          guest_options: line_item.guest_options,
          date_unit_options: date_unit_options
        ).call
      end

      # TODO: find better to get actual booking date.
      def booking_date
        line_item.created_at
      end
    end
  end
end
