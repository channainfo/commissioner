require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingRules::GroupBooking, type: :model do
  let(:eligible_quantity) { 1 }

  subject { create(:cm_group_pricing_rule, quantity: eligible_quantity) }

  describe "validations" do
    it "invalid when preferred_quantity is < 0" do
      subject.preferred_quantity = -1

      expect(subject.valid?).to be false
      expect(subject.errors[:preferred_quantity]).to include("must be greater than 0")
    end

    it "invalid when preferred_quantity is = 0" do
      subject.preferred_quantity = -1

      expect(subject.valid?).to be false
      expect(subject.errors[:preferred_quantity]).to include("must be greater than 0")
    end

    it "valid when preferred_quantity is greater than 0" do
      subject.preferred_quantity = 3

      expect(subject.valid?).to be true
    end
  end

  describe "#applicable?" do
    it "returns true if options is a Pricings::Options, total_quantity & quantity_position is present" do
      options = SpreeCmCommissioner::Pricings::Options.new(quantity_position: 1, total_quantity: 3)
      expect(subject.applicable?(options)).to be true
    end

    it "returns false if options is not a Pricings::Options" do
      options = double("SomeOtherClass")
      expect(subject.applicable?(options)).to be false
    end

    it "returns false if quantity_position is not present" do
      options = SpreeCmCommissioner::Pricings::Options.new(quantity_position: nil, total_quantity: 3)
      expect(subject.applicable?(options)).to be false
    end

    it "returns false if total_quantity is not present" do
      options = SpreeCmCommissioner::Pricings::Options.new(quantity_position: 1, total_quantity: nil)
      expect(subject.applicable?(options)).to be false
    end
  end

  describe "#eligible?" do
    context 'when eligible group is 3' do
      let(:eligible_quantity) { 3 }

      context 'when user purchase 14 quantity' do
        it "eligible for quantity position between 1 to 12" do
          options = SpreeCmCommissioner::Pricings::Options.new(total_quantity: 14, quantity_position: 4)

          expect(subject.calculate_max_eligible_position(14)).to eq 12
          expect(subject.eligible?(options)).to be true
        end

        it "ineligible for quantity position after 12" do
          options = SpreeCmCommissioner::Pricings::Options.new(total_quantity: 14, quantity_position: 13)

          expect(subject.calculate_max_eligible_position(14)).to eq 12
          expect(subject.eligible?(options)).to be false
        end
      end
    end
  end

  describe "#description" do
    it "returns the description with preferred quantity" do
      expect(subject.description).to eq("Group booking with 1 quantity")
    end
  end
end
