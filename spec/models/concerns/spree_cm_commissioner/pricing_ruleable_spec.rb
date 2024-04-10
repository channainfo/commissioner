require 'spec_helper'

class PricingRuleableDummyClass < Spree::Base
  include SpreeCmCommissioner::PricingRuleable

  self.table_name = "cm_pricing_rates"

  after_initialize { self.pricing_rateable_id = 0 }
  after_initialize { self.pricing_rateable_type = 'Any' }
end

RSpec.describe SpreeCmCommissioner::PricingRuleable do
  let(:dummy_klass) { PricingRuleableDummyClass }

  subject { dummy_klass.new }

  describe 'associations' do
    it { should have_many(:pricing_rules).class_name('SpreeCmCommissioner::PricingRule').dependent(:destroy) }
  end

  describe "scopes" do
    describe ".active" do
      let!(:active_rate) { dummy_klass.create(effective_from: 1.day.ago, effective_to: 1.day.from_now) }
      let!(:permanent_rate) { dummy_klass.create(effective_from: nil, effective_to: nil) }

      let!(:inactive_rate) { dummy_klass.create(effective_from: 2.days.ago, effective_to: 1.day.ago) }
      let!(:future_rate) { dummy_klass.create(effective_from: 1.day.from_now, effective_to: 2.days.from_now) }

      it "returns active & permanent rates" do
        expect(dummy_klass.active).to include(active_rate, permanent_rate)
        expect(dummy_klass.active).not_to include(inactive_rate, future_rate)
      end
    end
  end

  describe '#eligible?' do
    let(:rule1) { build(:cm_pricing_rule) }
    let(:rule2) { build(:cm_pricing_rule) }

    subject { dummy_klass.new(pricing_rules: [rule1, rule2], match_policy: :all) }

    it 'return false when no applicable rules' do
      allow(rule1).to receive(:applicable?).with({}).and_return(false)
      allow(rule2).to receive(:applicable?).with({}).and_return(false)

      expect(subject.eligible?({})).to be false
    end

    context 'when pring rate is must match all rules' do
      subject { dummy_klass.new(pricing_rules: [rule1, rule2], match_policy: :all) }

      before do
        allow(rule1).to receive(:applicable?).with({}).and_return(true)
        allow(rule2).to receive(:applicable?).with({}).and_return(true)
      end

      it 'return false any of rules are not eligible' do
        allow(rule1).to receive(:eligible?).with({}).and_return(true)
        allow(rule2).to receive(:eligible?).with({}).and_return(false)

        expect(subject.eligible?({})).to be false
      end

      it 'return true all rules are eligible' do
        allow(rule1).to receive(:eligible?).with({}).and_return(true)
        allow(rule2).to receive(:eligible?).with({}).and_return(true)

        expect(subject.eligible?({})).to be true
      end
    end

    context 'when pring rate is must match any rules' do
      subject { dummy_klass.new(pricing_rules: [rule1, rule2], match_policy: :any) }

      before do
        allow(rule1).to receive(:applicable?).with({}).and_return(true)
        allow(rule2).to receive(:applicable?).with({}).and_return(true)
      end

      it 'return false when all of rules are not eligible' do
        allow(rule1).to receive(:eligible?).with({}).and_return(false)
        allow(rule2).to receive(:eligible?).with({}).and_return(false)

        expect(subject.eligible?({})).to be false
      end

      it 'return true any of rules are eligible' do
        allow(rule1).to receive(:eligible?).with({}).and_return(true)
        allow(rule2).to receive(:eligible?).with({}).and_return(false)

        expect(subject.eligible?({})).to be true
      end

      it 'return true all of rules are eligible' do
        allow(rule1).to receive(:eligible?).with({}).and_return(true)
        allow(rule2).to receive(:eligible?).with({}).and_return(true)

        expect(subject.eligible?({})).to be true
      end
    end

    context 'when pring rate is must match none of rules' do
      subject { dummy_klass.new(pricing_rules: [rule1, rule2], match_policy: :none) }

      before do
        allow(rule1).to receive(:applicable?).with({}).and_return(true)
        allow(rule2).to receive(:applicable?).with({}).and_return(true)
      end

      it 'return false when all of rules are eligible' do
        allow(rule1).to receive(:eligible?).with({}).and_return(true)
        allow(rule2).to receive(:eligible?).with({}).and_return(true)

        expect(subject.eligible?({})).to be false
      end

      it 'return false when some of rules are eligible' do
        allow(rule1).to receive(:eligible?).with({}).and_return(true)
        allow(rule2).to receive(:eligible?).with({}).and_return(false)

        expect(subject.eligible?({})).to be false
      end

      it 'return true all of rules are not eligible' do
        allow(rule1).to receive(:eligible?).with({}).and_return(false)
        allow(rule2).to receive(:eligible?).with({}).and_return(false)

        expect(subject.eligible?({})).to be true
      end
    end
  end
end
