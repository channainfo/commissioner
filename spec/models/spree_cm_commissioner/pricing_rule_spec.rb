require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingRule, type: :model do
  describe 'associations' do
    it { should belong_to(:pricing_ruleable).inverse_of(:pricing_rules).required }
  end

  describe '#applicable?' do
    it 'raises an error instructing to implement on sub-class' do
      pricing_rule = described_class.new
      expect { pricing_rule.applicable? }.to raise_error('Implement on sub-class of SpreeCmCommissioner::PricingRule')
    end
  end

  describe '#eligible?' do
    it 'raises an error instructing to implement on sub-class' do
      pricing_rule = described_class.new
      expect { pricing_rule.eligible? }.to raise_error('Implement on sub-class of SpreeCmCommissioner::PricingRule')
    end
  end

  describe '#description' do
    it 'raises an error instructing to implement on sub-class' do
      pricing_rule = described_class.new
      expect { pricing_rule.description }.to raise_error('Implement on sub-class of SpreeCmCommissioner::PricingRule')
    end
  end
end
