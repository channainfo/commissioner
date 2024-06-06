# Calculate the amount for line items by combining eligible rates and pricing models.
module SpreeCmCommissioner
  module Pricings
    class LineItemPricingsCalculator
      attr_reader :line_item,
                  :previous_applied_pricing_rate_ids,
                  :previous_applied_pricing_model_ids

      def initialize(line_item:)
        @line_item = line_item
        @previous_applied_pricing_rate_ids = line_item.applied_pricing_rates.pluck(:id)
        @previous_applied_pricing_model_ids = line_item.applied_pricing_models.pluck(:id)
      end

      def call
        ActiveRecord::Base.transaction do
          apply_pricings
          persist_totals
          delete_previous_pricings
        end
      end

      # date_range could be number of nights, or days or hours depending on usecases
      # For example:
      # - accomodation uses number of nights.
      # - appointment uses number of hours, etc.
      def apply_pricings
        line_item.applied_pricing_rates = []
        line_item.applied_pricing_models = []

        if line_item.reservation?
          line_item.date_range.map.each_with_index do |_date, date_index|
            date_options = DateOptions.new(date_index: date_index, date_range: line_item.date_range)
            line_item.applied_pricing_rates += build_pricing_rates(date_options: date_options) || []
            line_item.applied_pricing_models += build_pricing_models(date_options: date_options) || []
          end
        else
          line_item.applied_pricing_rates += build_pricing_rates(date_options: nil) || []
          line_item.applied_pricing_models += build_pricing_models(date_options: nil) || []
        end
      end

      def persist_totals
        line_item.pricing_rates_amount = line_item.applied_pricing_rates.map(&:amount).sum
        line_item.pricing_models_amount = line_item.applied_pricing_models.map(&:amount).sum || 0
        line_item.pricing_subtotal = [0, line_item.pricing_rates_amount + line_item.pricing_models_amount].max

        line_item.save!
      end

      def delete_previous_pricings
        AppliedPricingModel.where(id: previous_applied_pricing_model_ids).delete_all
        AppliedPricingRate.where(id: previous_applied_pricing_rate_ids).delete_all
      end

      def build_pricing_rates(date_options: nil)
        options = base_options.copy_with(date_options: date_options)
        VariantPricingRatesComputer.new(variant: line_item.variant, base_options: options).call
      end

      def build_pricing_models(date_options: nil)
        options = base_options.copy_with(date_options: date_options)
        VariantPricingModelsComputer.new(variant: line_item.variant, base_options: options).call
      end

      def base_options
        Options.new(
          total_quantity: line_item.quantity,
          booking_date: booking_date,
          guest_options: line_item.guest_options
        )
      end

      # TODO: find better to get actual booking date.
      def booking_date
        line_item.created_at
      end
    end
  end
end
