require 'spec_helper'

RSpec.describe SpreeCmCommissioner::AppliedPricingModel, type: :model do
  describe '#display_amount' do
    let(:line_item) { create(:line_item) }
    let(:pricing_model) { create(:cm_pricing_model, modelable: line_item.variant) }

    subject { line_item.applied_pricing_models.create(pricing_model: pricing_model, amount: 10, line_item: line_item) }

    it 'return correct display amount' do
      expect(subject.display_amount.to_s).to eq '$10.00'
    end
  end
end
