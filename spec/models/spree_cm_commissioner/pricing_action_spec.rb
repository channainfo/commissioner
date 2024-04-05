require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingAction, type: :model do
  describe 'associations' do
    it { should belong_to(:pricing_model).class_name('SpreeCmCommissioner::PricingModel').required }
  end

  describe '#applicable?' do
    it 'raises an error' do
      expect { subject.applicable?({}) }.to raise_error('Implement on sub-class of SpreeCmCommissioner::PricingAction')
    end
  end

  describe '#perform' do
    it 'raises an error' do
      expect { subject.perform({}) }.to raise_error('Implement on sub-class of SpreeCmCommissioner::PricingAction')
    end
  end
end
