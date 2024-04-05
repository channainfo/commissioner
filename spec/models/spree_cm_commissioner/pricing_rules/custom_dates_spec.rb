require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingRules::CustomDates, type: :model do
  let(:options) { SpreeCmCommissioner::Pricings::Options.new(date_options: date_options) }

  describe "#applicable?" do
    context "when options is not Pricings::Options" do
      let(:options) { double(:random_object) }

      it "returns false" do
        expect(subject.applicable?(options)).to be false
      end
    end

    context "when date_options is not Pricings::DateOptions" do
      let(:date_options) { double(:random_object) }

      it "returns false" do
        expect(subject.applicable?(options)).to be false
      end
    end

    context "when date is present in options" do
      let(:date) { Date.current }
      let(:date_options) { SpreeCmCommissioner::Pricings::DateOptions.new(date_index: 0, date_range: [date]) }

      it "returns true" do
        expect(date_options.date).to eq date
        expect(subject.applicable?(options)).to be true
      end
    end

    context "when date is not present in options" do
      let(:date_options) { SpreeCmCommissioner::Pricings::DateOptions.new(date_index: 0, date_range: []) }

      it "returns false" do
        expect(date_options.date).to eq nil
        expect(subject.applicable?(options)).to be false
      end
    end
  end

  describe '#eligible?' do
    let(:date_options) { SpreeCmCommissioner::Pricings::DateOptions.new(date_index: 0, date_range: [date]) }

    # TODO:
  end
end
