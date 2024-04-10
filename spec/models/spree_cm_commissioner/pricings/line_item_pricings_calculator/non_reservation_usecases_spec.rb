require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Pricings::LineItemPricingsCalculator do
  include GuestOptionsHelper

  subject { described_class.new(line_item: line_item) }

  context 'when product is not reservation (ecommerce)' do
    context 'variant has eligible rate & model' do
      context 'has early bird rate & group booking model' do
        let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current, to: Date.current + 2.days) }

        let(:quantity_3_rule) { build(:cm_group_pricing_rule, quantity: 3) }
        let(:quantity_4_rule) { build(:cm_group_pricing_rule, quantity: 4) }

        let(:pricing_rate) { build(:cm_pricing_rate, pricing_rules: [early_bird_rule], price: 50) }
        let(:pricing_model1) { build(:cm_pricing_model, pricing_rules: [quantity_3_rule], percent_adjustment: 10) }
        let(:pricing_model2) { build(:cm_pricing_model, pricing_rules: [quantity_4_rule], percent_adjustment: 15) }

        let(:product) { create(:product) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [pricing_rate], pricing_models: [pricing_model1, pricing_model2]) }

        let(:line_item) { create(:line_item, variant: variant, quantity: 8, created_at: Date.current) }

        before { subject.call }

        it 'update to new early bird rate for all 8 quantity' do
          expect(line_item.applied_pricing_rates.size).to eq 8 # 8 applied-rates for each quantity

          expect(line_item.pricing_rates_amount).to eq 50 * 8
        end

        it 'update 10% adjustment for 3 quantity & 15% adjustment for 4 quantity' do
          first_3_rooms = 50 * 0.10 * 3
          last_4_rooms = 50 * 0.15 * 4

          expect(line_item.applied_pricing_models.size).to eq 8 # 8 applied-models for each quantity

          expect(line_item.pricing_models_amount).to eq first_3_rooms + last_4_rooms
        end

        it 'update new subtotal combined of applied rate + applied model' do
          rate_amount = 50 * 8
          model_amount = 50 * 0.10 * 3 + 50 * 0.15 * 4

          expect(line_item.pricing_subtotal).to eq rate_amount + model_amount
        end
      end
    end

    context 'when variant may have an eligible rate, model, or neither' do
      context 'has NO eligible rate but has eligible model' do
        let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current + 7.days, to: Date.current + 10.days) }
        let(:quantity_rule) { build(:cm_group_pricing_rule, quantity: 3) }

        let(:ineligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [early_bird_rule], price: 50) }
        let(:eligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [quantity_rule], percent_adjustment: 10) }

        let(:product) { create(:product) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [ineligible_pricing_rate], pricing_models: [eligible_pricing_model]) }
        let(:line_item) { create(:line_item, variant: variant, quantity: 3, created_at: Date.current) }

        before { subject.call }

        it 'update pricing_rates_amount to normal rate for all 3 quantity' do
          expect(line_item.applied_pricing_rates.size).to eq 3 # 3 applied-rates for each quantity

          expect(line_item.pricing_rates_amount).to eq 40 * 3
        end

        it 'update 10% adjustment for all 3 quantity' do
          expect(line_item.applied_pricing_models.size).to eq 3 # 3 applied-models for each quantity

          expect(line_item.pricing_models_amount).to eq (40 * 3) * 0.1
        end

        it 'update new subtotal combined of applied rate + applied model' do
          expect(line_item.pricing_subtotal).to eq (40 * 3) + (40 * 3) * 0.1
        end
      end

      context 'has eligible rate & NO eligible model' do
        let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current, to: Date.current + 3.days) }
        let(:quantity_rule) { build(:cm_group_pricing_rule, quantity: 4) }

        let(:eligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [early_bird_rule], price: 50) }
        let(:ineligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [quantity_rule], percent_adjustment: 10) }

        let(:product) { create(:product) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [eligible_pricing_rate], pricing_models: [ineligible_pricing_model]) }
        let(:line_item) { create(:line_item, variant: variant, quantity: 3, created_at: Date.current) }

        before { subject.call }

        it 'update to new early bird rate for all 3 quantity' do
          expect(line_item.applied_pricing_rates.size).to eq 3 # 3 applied-rates for each quantity

          expect(line_item.pricing_rates_amount).to eq 50 * 3
        end

        it 'update pricing_models_amount to 0' do
          expect(line_item.applied_pricing_models.size).to eq 0

          expect(line_item.pricing_models_amount).to eq 0
        end

        it 'update new subtotal combined of applied rate + applied model' do
          expect(line_item.pricing_subtotal).to eq(50 * 3)
        end
      end

      context 'has NO eligible rate & model' do
        let(:early_bird_rule) { build(:cm_early_bird_pricing_rule, from: Date.current + 7.days, to: Date.current + 10.days) }
        let(:quantity_rule) { build(:cm_group_pricing_rule, quantity: 4) }

        let(:ineligible_pricing_rate) { build(:cm_pricing_rate, pricing_rules: [early_bird_rule], price: 50) }
        let(:ineligible_pricing_model) { build(:cm_pricing_model, pricing_rules: [quantity_rule], percent_adjustment: 10) }

        let(:product) { create(:product) }
        let(:variant) { create(:variant, price: 40, product: product, pricing_rates: [ineligible_pricing_rate], pricing_models: [ineligible_pricing_model]) }
        let(:line_item) { create(:line_item, variant: variant, quantity: 3, created_at: Date.current) }

        before { subject.call }

        it 'update pricing_rates_amount to normal rate for all 3 quantity' do
          expect(line_item.applied_pricing_rates.size).to eq 3 # 3 applied-rates for each quantity

          expect(line_item.pricing_rates_amount).to eq 40 * 3
        end

        it 'update pricing_models_amount to 0' do
          expect(line_item.applied_pricing_models.size).to eq 0

          expect(line_item.pricing_models_amount).to eq 0
        end

        it 'update new subtotal combined of applied rate + applied model' do
          expect(line_item.pricing_subtotal).to eq 40 * 3 + 0
        end
      end
    end
  end
end
