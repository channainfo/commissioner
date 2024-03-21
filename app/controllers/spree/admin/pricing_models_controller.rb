module Spree
  module Admin
    class PricingModelsController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def collection
        parent.variants

        accomodation_models + ecommerce_models
      end

      def ecommerce_models
        [
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::GroupBooking.new(preferred_min_quantity: 5, preferred_max_quantity: 5)
            ],
            pricing_actions: [
              SpreeCmCommissioner::PricingActions::BuildAdjustmentForEligibleQuantity.new(calculator: Spree::Calculator::FlatRate.new(preferred_amount: 10, preferred_currency: current_currency)) # rubocop:disable Layout/LineLength
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::EarlyBird.new(preferred_booking_date_from: Date.current + 10.days, preferred_booking_date_to: Date.current + 15.days) # rubocop:disable Layout/LineLength
            ],
            pricing_actions: [
              SpreeCmCommissioner::PricingActions::BuildAdjustmentForEligibleQuantity.new(calculator: Spree::Calculator::FlatRate.new(preferred_amount: -10, preferred_currency: current_currency)) # rubocop:disable Layout/LineLength
            ]
          )
        ]
      end

      def accomodation_models
        [
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::ExtraAdults.new(preferred_min_extra_adults: 2, preferred_max_extra_adults: 2)
            ],
            pricing_actions: [
              SpreeCmCommissioner::PricingActions::BuildAdjustmentForEligibleStayDates.new(calculator: Spree::Calculator::PercentOnLineItem.new(preferred_percent: 10))
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::ExtraKids.new(preferred_min_extra_kids: 1, preferred_max_extra_kids: 2)
            ],
            pricing_actions: [
              # build adjustment for each day
              SpreeCmCommissioner::PricingActions::BuildAdjustmentForEligibleStayDates.new(calculator: Spree::Calculator::FlatRate.new(preferred_amount: 10, preferred_currency: current_currency)) # rubocop:disable Layout/LineLength
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::LongStay.new(preferred_min_stay_duration_in_nights: 5, preferred_max_stay_duration_in_nights: 10)
            ],
            pricing_actions: [
              SpreeCmCommissioner::PricingActions::BuildAdjustmentForEligibleStayDates.new(calculator: Spree::Calculator::FlatRate.new(preferred_amount: 10, preferred_currency: current_currency)) # rubocop:disable Layout/LineLength
            ]
          )
        ]
      end

      # override
      def model_class
        SpreeCmCommissioner::PricingModel
      end

      # override
      def object_name
        'spree_cm_commissioner_pricing_model'
      end
    end
  end
end
