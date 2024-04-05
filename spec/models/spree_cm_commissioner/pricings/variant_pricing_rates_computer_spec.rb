require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Pricings::VariantPricingRatesComputer do
  let(:total_quantity) { 2 }
  let(:booking_date) { Date.current }
  let(:guest_options) { nil }
  let(:date_options) { nil }
  let(:base_options) do
    SpreeCmCommissioner::Pricings::Options.new(
      total_quantity: total_quantity,
      booking_date: booking_date,
      guest_options: guest_options,
      date_options: date_options,
    )
  end

  subject { described_class.new(variant: variant, base_options: base_options) }

  describe '#call' do
    let!(:variant) { create(:variant, price: 20) }

    let(:applied_rate_1) { SpreeCmCommissioner::AppliedPricingRate.new(amount: 10) }
    let(:applied_rate_2) { SpreeCmCommissioner::AppliedPricingRate.new(amount: 10) }

    it 'loop through each quantity unit' do
      expect(subject).to receive(:apply_rate_for).with(quantity_position: 1).once
      expect(subject).to receive(:apply_rate_for).with(quantity_position: 2).once

      subject.call
    end

    it 'loop through each quantity & return 2 applied rate for each quantity' do
      allow(subject).to receive(:apply_rate_for).with(quantity_position: 1).and_return(applied_rate_1)
      allow(subject).to receive(:apply_rate_for).with(quantity_position: 2).and_return(applied_rate_2)

      applied_rates = subject.call

      expect(applied_rates[0]).to eq applied_rate_1
      expect(applied_rates[1]).to eq applied_rate_2
    end
  end

  describe '#apply_rate_for' do
    let(:rate_12_dollar) { build(:cm_pricing_rate, price: 12) }
    let(:rate_15_dollar) { build(:cm_pricing_rate, price: 15) }
    let!(:variant) { create(:variant, price: 20, pricing_rates: [rate_12_dollar, rate_15_dollar]) }

    context 'when multiple rates are eligible' do
      before do
        allow(rate_12_dollar).to receive(:eligible?).and_return(true)
        allow(rate_15_dollar).to receive(:eligible?).and_return(true)
      end

      it 'returns rate that is found eligible first for that position' do
        applied_rate = subject.apply_rate_for(quantity_position: 1)

        expect(applied_rate.pricing_rate).to eq rate_12_dollar
        expect(applied_rate.amount).to eq rate_12_dollar.price
      end
    end

    context 'when only rate_15_dollar is eligible' do
      before do
        allow(rate_12_dollar).to receive(:eligible?).and_return(false)
        allow(rate_15_dollar).to receive(:eligible?).and_return(true)
      end

      it 'returns rate_15_dollar for that position of quantity' do
        applied_rate = subject.apply_rate_for(quantity_position: 1)

        expect(applied_rate.pricing_rate).to eq rate_15_dollar
        expect(applied_rate.amount).to eq rate_15_dollar.price
      end
    end

    context 'when no eligible rates' do
      before do
        allow(rate_12_dollar).to receive(:eligible?).and_return(false)
        allow(rate_15_dollar).to receive(:eligible?).and_return(false)
      end

      it 'returns normal rate for both quantity positions' do
        applied_rate = subject.apply_rate_for(quantity_position: 1)

        expect(applied_rate.pricing_rate).to eq nil
        expect(applied_rate.amount).to eq variant.price
      end
    end
  end
end
