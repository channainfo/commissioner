require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Pricings::VariantPricingModelsComputer do
  include GuestOptionsHelper

  let(:total_quantity) { 2 }
  let(:booking_date) { Date.current }
  let(:guest_options) { nil }
  let(:date_options) { nil }
  let(:base_options) do
    options_klass.new(
      total_quantity: total_quantity,
      booking_date: booking_date,
      guest_options: guest_options,
      date_options: date_options,
    )
  end

  subject { described_class.new(variant: variant, base_options: base_options) }

  describe '#call' do
    let!(:variant) { create(:variant, price: 20) }

    let(:applied_model_1) { SpreeCmCommissioner::AppliedPricingModel.new(amount: 10) }
    let(:applied_model_2) { SpreeCmCommissioner::AppliedPricingModel.new(amount: 10) }

    it 'loop through each quantity unit' do
      expect(subject).to receive(:apply_model_for).with(quantity_position: 1).once
      expect(subject).to receive(:apply_model_for).with(quantity_position: 2).once

      subject.call
    end

    it 'loop through each quantity & return 2 applied models for each quantity' do
      allow(subject).to receive(:apply_model_for).with(quantity_position: 1).and_return(applied_model_1)
      allow(subject).to receive(:apply_model_for).with(quantity_position: 2).and_return(applied_model_2)

      applied_models = subject.call

      expect(applied_models.size).to eq 2
      expect(applied_models[0]).to eq applied_model_1
      expect(applied_models[1]).to eq applied_model_2
    end

    it 'loop through each quantity & only return 1 applied model where it is not null' do
      allow(subject).to receive(:apply_model_for).with(quantity_position: 1).and_return(applied_model_1)
      allow(subject).to receive(:apply_model_for).with(quantity_position: 2).and_return(nil)

      applied_models = subject.call

      expect(applied_models.size).to eq 1
      expect(applied_models[0]).to eq applied_model_1
    end
  end

  describe '#apply_model_for' do
    context 'when model is flat rate (eg. +10$ or -10$)' do
      let(:model_12_dollar) { build(:cm_pricing_model, flat_adjustment: 12) }
      let(:model_15_dollar) { build(:cm_pricing_model, flat_adjustment: 15) }
      let!(:variant) { create(:variant, price: 20, pricing_models: [model_12_dollar, model_15_dollar]) }

      context 'when multiple models are eligible' do
        before do
          allow(model_12_dollar).to receive(:eligible?).and_return(true)
          allow(model_15_dollar).to receive(:eligible?).and_return(true)
        end

        it 'returns model that is found eligible first for that position' do
          applied_model = subject.apply_model_for(quantity_position: 1)

          expect(applied_model.pricing_model).to eq model_12_dollar
          expect(applied_model.amount).to eq 12
        end
      end

      context 'when only model_15_dollar is eligible' do
        before do
          allow(model_12_dollar).to receive(:eligible?).and_return(false)
          allow(model_15_dollar).to receive(:eligible?).and_return(true)
        end

        it 'returns model_15_dollar for that position of quantity' do
          applied_model = subject.apply_model_for(quantity_position: 1)

          expect(applied_model.pricing_model).to eq model_15_dollar
          expect(applied_model.amount).to eq 15
        end
      end

      context 'when no eligible models' do
        before do
          allow(model_12_dollar).to receive(:eligible?).and_return(false)
          allow(model_15_dollar).to receive(:eligible?).and_return(false)
        end

        it 'returns nil' do
          applied_model = subject.apply_model_for(quantity_position: 1)

          expect(applied_model).to eq nil
        end
      end
    end

    context 'when model is percent rate (eg. +10% or -10%)' do
      let(:model_10_percent) { build(:cm_pricing_model, percent_adjustment: 10) }
      let(:rate_50_dollar) { build(:cm_pricing_rate, price: 50) }

      let!(:variant) { create(:variant, price: 20, pricing_models: [model_10_percent], pricing_rates: [rate_50_dollar]) }

      context 'when a pricing model is eligible' do
        before { allow(model_10_percent).to receive(:eligible?).and_return(true) }

        context 'when a pricing rate is also eligible' do
          before { allow(rate_50_dollar).to receive(:eligible?).and_return(true) }

          it 'calculate percent model on top of rate amount' do
            applied_model = subject.apply_model_for(quantity_position: 1)

            # 10 percent of 50$
            expect(applied_model.amount).to eq 5

            expect(applied_model.pricing_model_id).to eq model_10_percent.id
            expect(applied_model.pricing_rate_id).to eq rate_50_dollar.id
          end
        end

        context 'when NO eligible pricing rate' do
          before { allow(rate_50_dollar).to receive(:eligible?).and_return(false) }

          it 'calculate percent model on top of normal rate' do
            applied_model = subject.apply_model_for(quantity_position: 1)

            # 10 percent of 20$
            expect(applied_model.amount).to eq 2
            expect(applied_model.pricing_model_id).to eq model_10_percent.id
            expect(applied_model.pricing_rate_id).to eq nil
          end
        end
      end

      context 'when no eligible pricing models' do
        before do
          allow(model_10_percent).to receive(:eligible?).and_return(false)
        end

        it 'returns nil' do
          applied_model = subject.apply_model_for(quantity_position: 1)

          expect(applied_model).to eq nil
        end
      end
    end
  end
end
