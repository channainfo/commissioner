require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingActions::CalculateAdjustment, type: :model do
  describe "#applicable?" do
    context "when total_quantity, rate_amount, and rate_currency are present" do
      let(:options) { SpreeCmCommissioner::Pricings::Options.new(total_quantity: 2, rate_amount: 10, rate_currency: 'USD') }

      it "returns true" do
        expect(subject.applicable?(options)).to be true
      end
    end

    context "when any of total_quantity, rate_amount, or rate_currency are missing" do
      let(:options1) { SpreeCmCommissioner::Pricings::Options.new(total_quantity: 2, rate_amount: 10, rate_currency: nil) }
      let(:options2) { SpreeCmCommissioner::Pricings::Options.new(total_quantity: 2, rate_amount: nil, rate_currency: 'USD') }
      let(:options3) { SpreeCmCommissioner::Pricings::Options.new(total_quantity: nil, rate_amount: 10, rate_currency: 'USD') }

      it "returns false" do
        expect(subject.applicable?(options1)).to be false
        expect(subject.applicable?(options2)).to be false
        expect(subject.applicable?(options3)).to be false
      end
    end
  end

  describe "#perform" do
    let(:options) { SpreeCmCommissioner::Pricings::Options.new(total_quantity: 2, rate_amount: 100, rate_currency: 'USD') }

    let(:variant) { create(:variant) }
    let(:pricing_model) { create(:cm_pricing_model, pricing_modelable: variant) }

    subject { create(:cm_calculate_adjustment_pricing_action, percent_adjustment: 10, pricing_model: pricing_model) }

    it "calls compute_amount with the given options" do
      expect(subject).to receive(:compute_amount).with(options).and_call_original
      expect(subject.perform(options)).to eq 10
    end
  end

  describe "#compute_amount" do
    let(:options) { SpreeCmCommissioner::Pricings::Options.new(total_quantity: 2, rate_amount: 15, rate_currency: 'USD') }

    let(:variant) { create(:variant) }
    let(:pricing_model) { create(:cm_pricing_model, pricing_modelable: variant) }

    context 'when calculator is flat rate' do
      subject { create(:cm_calculate_adjustment_pricing_action, flat_adjustment: -3, pricing_model: pricing_model) }

      it "computes the amount based on the options" do
        expect(subject.compute_amount(options)).to eq -3
      end
    end

    context 'when calculator is percent rate' do
      subject { create(:cm_calculate_adjustment_pricing_action, percent_adjustment: 10, pricing_model: pricing_model) }

      it "computes the amount based on the options" do
        expect(subject.compute_amount(options)).to eq 1.5
      end
    end
  end
end
