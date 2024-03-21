module Spree
  module Admin
    class PricingRatesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def collection
        parent.variants

        accomodation_rates + ecommerce_rates
        # ecommerce_rates
      end

      def accomodation_rates # rubocop:disable Metrics/AbcSize
        [
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::EarlyBird.new(preferred_booking_date_from: Date.current + 10.days, preferred_booking_date_to: Date.current + 15.days)
            ],
            prices: [
              Spree::Price.new(price: 70, currency: current_currency)
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::Weekdays.new(preferred_weekdays: %w[6, 0]),
              SpreeCmCommissioner::PricingRules::CustomDates.new(preferred_custom_dates: [{ start_date: '2023-12-07', length: '1', title: 'Public Holiday' }]) # rubocop:disable Layout/LineLength
            ],
            prices: [
              Spree::Price.new(price: 70, currency: current_currency)
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::Weekdays.new(preferred_weekdays: %w[6 0])
            ],
            prices: [
              Spree::Price.new(price: 75, currency: current_currency)
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::CustomDates.new(preferred_custom_dates: [{ start_date: '2023-12-07', length: '1', title: 'Public Holiday' }]) # rubocop:disable Layout/LineLength
            ],
            prices: [
              Spree::Price.new(price: 80, currency: current_currency)
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::Weekdays.new(preferred_weekdays: %w[6 0]),
              SpreeCmCommissioner::PricingRules::LongStay.new(preferred_min_stay_duration_in_nights: 5, preferred_max_stay_duration_in_nights: 10)
            ],
            prices: [
              Spree::Price.new(price: 80, currency: current_currency)
            ]
          )
        ]
      end

      def ecommerce_rates
        [
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::GroupBooking.new(preferred_min_quantity: 3, preferred_max_quantity: 3)
            ],
            prices: [
              Spree::Price.new(price: 100, currency: current_currency)
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::GroupBooking.new(preferred_min_quantity: 5, preferred_max_quantity: 5)
            ],
            prices: [
              Spree::Price.new(price: 180, currency: current_currency)
            ]
          ),
          model_class.new(
            effective_from: Date.current, effective_to: Date.current + 30.days,
            pricing_rules: [
              SpreeCmCommissioner::PricingRules::GroupBooking.new(preferred_min_quantity: 10, preferred_max_quantity: 10)
            ],
            prices: [
              Spree::Price.new(price: 350, currency: current_currency)
            ]
          )
        ]
      end

      # override
      def model_class
        SpreeCmCommissioner::PricingRate
      end

      # override
      def object_name
        'pricing_rate'
      end
    end
  end
end
