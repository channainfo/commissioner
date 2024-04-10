require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Pricings::LineItemPricingsCalculator do
  include GuestOptionsHelper

  subject { described_class.new(line_item: line_item) }

  context 'when product is reservation (accomodation or service with date present)' do
    let(:date1) { Date.current }
    let(:date2) { Date.current + 1.days }
    let(:date3) { Date.current + 2.days }
    let(:date4) { Date.current + 3.days }

    context 'variant has eligible rate & model' do
      context 'has custom-date rate & extra-adults model' do
        let(:date_rule) { build(:cm_custom_date_pricing_rule, dates: [date1, date2]) }
        let(:extra_adults_rule) { build(:cm_extra_adults_pricing_rule, extra_adults: 2) }

        let(:pricing_rate) { build(:cm_pricing_rate, pricing_rules: [date_rule], price: 50) }
        let(:pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_adults_rule], percent_adjustment: 10) }

        let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :adults), create(:cm_option_type, :allowed_extra_adults)]) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [pricing_rate], pricing_models: [pricing_model], option_values: [adults(4), allowed_extra_adults(2)]) }

        let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_adults: 6 }) }

        let!(:previous_rate) { line_item.applied_pricing_rates.create!(pricing_rate: pricing_rate, amount: 10) }
        let!(:previous_model) { line_item.applied_pricing_models.create!(pricing_model: pricing_model, amount: 4) }

        before { subject.call }

        it 'update rate to new rate amount on night 1,2 & default rate on night 3' do
          line_item.reload

          expect(line_item.date_range.size).to eq 3
          expect(line_item.applied_pricing_rates.size).to eq 3 # 3 applied-rates for each 3 nights x 1 room

          expect(line_item.pricing_rates_amount).to eq 50 + 50 + 40
        end

        it 'update adjustment 10% adjustment for extra 2 adults for all 3-nights' do
          expect(line_item.applied_pricing_models.size).to eq 3 # 3 applied-models for each 3 nights x 1 room

          expect(line_item.pricing_models_amount).to eq (50 + 50 + 40) * 0.1
        end

        it 'update new subtotal combined of applied rate + applied model' do
          expect(line_item.pricing_subtotal).to eq (50 + 50 + 40) + (50 + 50 + 40) * 0.1
        end

        it 'deleted previous pricings' do
          expect { previous_rate.reload }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find SpreeCmCommissioner::AppliedPricingRate with 'id'=#{previous_rate.id}")
          expect { previous_model.reload }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find SpreeCmCommissioner::AppliedPricingModel with 'id'=#{previous_model.id}")
        end
      end

      context 'has weekdays rate & extra-kids model' do
        let(:weekday_rule) { build(:cm_weekend_pricing_rule, weekend_days: [date1.wday, date2.wday]) }
        let(:extra_kids_rule) { build(:cm_extra_kids_pricing_rule, extra_kids: 2) }

        let(:pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
        let(:pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_kids_rule], percent_adjustment: 10) }

        let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [pricing_rate], pricing_models: [pricing_model], option_values: [kids(3), allowed_extra_kids(2)]) }

        let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_kids: 5 }) }

        before { subject.call }

        it 'update rate to new rate amount on night 1,2 & default rate on night 3' do
          expect(line_item.applied_pricing_rates.size).to eq 3 # 3 applied-rates for each 3 nights x 1 room

          expect(line_item.pricing_rates_amount).to eq 50+50+40
        end

        it 'update adjustment to 10% adjustment for extra 2 kids for all 3-nights' do
          expect(line_item.applied_pricing_models.size).to eq 3 # 3 applied-models for each 3 nights x 1 room

          expect(line_item.pricing_models_amount).to eq (50+50+40) * 0.1
        end

        it 'update new subtotal combined of applied rate + applied model' do
          expect(line_item.pricing_subtotal).to eq (50+50+40) + (50+50+40) * 0.1
        end
      end

      context 'has weekdays rate & group booking model' do
        let(:weekday_rule) { build(:cm_weekend_pricing_rule, weekend_days: [date1.wday, date2.wday]) }

        let(:quantity_3_rule) { build(:cm_group_pricing_rule, quantity: 3) }
        let(:quantity_4_rule) { build(:cm_group_pricing_rule, quantity: 4) }

        let(:pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
        let(:pricing_model1) { build(:cm_pricing_model, pricing_rules: [quantity_3_rule], percent_adjustment: 10) }
        let(:pricing_model2) { build(:cm_pricing_model, pricing_rules: [quantity_4_rule], percent_adjustment: 15) }

        let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [pricing_rate], pricing_models: [pricing_model1, pricing_model2], option_values: [kids(3), allowed_extra_kids(2)]) }

        let(:line_item) { create(:line_item, variant: variant, quantity: 8, from_date: date1, to_date: date4) }

        before { subject.call }

        it 'update rate to new rate amount on night 1,2 & default rate on night 3 for all 8 rooms' do
          expect(line_item.applied_pricing_rates.size).to eq 8 * 3 # 24 applied-rates for each 3 nights x 8 rooms

          expect(line_item.pricing_rates_amount).to eq (50+50+40) * 8
        end

        it 'update adjustment to 10% adjustment for 3 room & 15% adjustment for 4 room' do
          first_3_rooms = (50+50+40) * 0.10 * 3
          last_4_rooms = (50+50+40) * 0.15 * 4

          expect(line_item.applied_pricing_models.size).to eq 8 * 3 # 24 applied-models for each 3 nights x 8 rooms

          expect(line_item.pricing_models_amount).to eq first_3_rooms + last_4_rooms
        end

        it 'update new subtotal combined of applied rate + applied model' do
          rate_amount = (50+50+40) * 8
          model_amount = (50+50+40) * 0.10 * 3 + (50+50+40) * 0.15 * 4

          expect(line_item.pricing_subtotal).to eq rate_amount + model_amount
        end
      end
    end

    context 'when variant may have an eligible rate, model, or neither' do
      context 'has NO eligible rate but has eligible model' do
        let(:weekday_rule) { build(:cm_weekend_pricing_rule, weekend_days: []) }
        let(:extra_kids_rule) { build(:cm_extra_kids_pricing_rule, extra_kids: 2) }

        let(:ineligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
        let(:eligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_kids_rule], percent_adjustment: 10) }

        let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [ineligible_pricing_rate], pricing_models: [eligible_pricing_model], option_values: [kids(3), allowed_extra_kids(2)]) }

        let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_kids: 5 }) }

        before { subject.call }

        it 'update pricing_rates_amount to normal rate for 3 nights' do
          expect(line_item.applied_pricing_rates.size).to eq 3
          expect(line_item.applied_pricing_rates[0].amount).to eq 40
          expect(line_item.applied_pricing_rates[1].amount).to eq 40
          expect(line_item.applied_pricing_rates[2].amount).to eq 40

          expect(line_item.pricing_rates_amount).to eq 40+40+40
        end

        it 'update adjustment to 10% adjustment for extra 2 kids for all 3-nights' do
          expect(line_item.applied_pricing_models.size).to eq 3
          expect(line_item.applied_pricing_models[0].amount).to eq 40 * 0.1
          expect(line_item.applied_pricing_models[1].amount).to eq 40 * 0.1
          expect(line_item.applied_pricing_models[2].amount).to eq 40 * 0.1

          expect(line_item.pricing_models_amount).to eq (40+40+40) * 0.1
        end

        it 'update new subtotal combined of applied rate + applied model' do
          expect(line_item.pricing_subtotal).to eq (40+40+40) + (40+40+40) * 0.1
        end
      end

      context 'has eligible weekend rate but NO eligible model' do
        let(:weekday_rule) { build(:cm_weekend_pricing_rule, weekend_days: [date1.wday, date2.wday]) }
        let(:extra_kids_rule) { build(:cm_extra_kids_pricing_rule, extra_kids: 3) }

        let(:eligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
        let(:ineligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_kids_rule], percent_adjustment: 10) }

        let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [eligible_pricing_rate], pricing_models: [ineligible_pricing_model], option_values: [kids(3), allowed_extra_kids(2)]) }

        let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_kids: 5 }) }

        before { subject.call }

        it 'update rate to new rate amount on night 1,2 & default rate on night 3' do
          expect(line_item.applied_pricing_rates.size).to eq 3
          expect(line_item.applied_pricing_rates[0].amount).to eq 50
          expect(line_item.applied_pricing_rates[1].amount).to eq 50
          expect(line_item.applied_pricing_rates[2].amount).to eq 40

          expect(line_item.pricing_rates_amount).to eq 50+50+40
        end

        it 'update pricing_models_amount to 0' do
          expect(line_item.applied_pricing_models.size).to eq 0

          expect(line_item.pricing_models_amount).to eq 0
        end

        it 'update new subtotal combined of applied rate + applied model' do
          expect(line_item.pricing_subtotal).to eq 50+50+40
        end
      end

      context 'has NO eligible weekend rate & model' do
        let(:weekday_rule) { build(:cm_weekend_pricing_rule, weekend_days: []) }
        let(:extra_kids_rule) { build(:cm_extra_kids_pricing_rule, extra_kids: 3) }

        let(:eligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [weekday_rule], price: 50) }
        let(:ineligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [extra_kids_rule], percent_adjustment: 10) }

        let(:product) { create(:cm_accommodation_product, option_types: [create(:cm_option_type, :kids), create(:cm_option_type, :allowed_extra_kids)]) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [eligible_pricing_rate], pricing_models: [ineligible_pricing_model], option_values: [kids(3), allowed_extra_kids(2)]) }

        let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: date1, to_date: date4, public_metadata: { number_of_kids: 5 }) }

        before { subject.call }

        it 'update pricing_rates_amount to normal rate for all 3 nights' do
          expect(line_item.applied_pricing_rates.size).to eq 3 # 3 applied-rates for each 3 nights x 1 quantity

          expect(line_item.pricing_rates_amount).to eq 40+40+40
        end

        it 'update pricing_models_amount to 0' do
          expect(line_item.applied_pricing_models.size).to eq 0

          expect(line_item.pricing_models_amount).to eq 0
        end

        it 'update new subtotal combined of applied rate + applied model' do
          expect(line_item.pricing_subtotal).to eq 40+40+40
        end
      end
    end
  end
end
