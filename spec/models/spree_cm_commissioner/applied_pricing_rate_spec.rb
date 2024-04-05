require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AppliedPricingRate, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:amount) }

    it 'validates numericality of amount' do
      expect(subject).to validate_numericality_of(:amount).is_greater_than_or_equal_to(0)
      expect(subject).to validate_numericality_of(:amount).is_less_than_or_equal_to(Spree::Price::MAXIMUM_AMOUNT)
    end
  end

  describe '#display_amount' do
    let(:line_item) { create(:line_item) }
    let(:pricing_rate) { create(:cm_pricing_rate, rateable: line_item.variant) }

    subject { line_item.applied_pricing_rates.create(pricing_rate: pricing_rate, amount: 10, line_item: line_item) }

    it 'return correct display amount' do
      expect(subject.display_amount.to_s).to eq '$10.00'
    end
  end
end
