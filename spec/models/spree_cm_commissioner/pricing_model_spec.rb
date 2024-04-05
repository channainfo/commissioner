require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingModel, type: :model do
  describe 'associations' do
    it { should belong_to(:modelable).inverse_of(:pricing_models).touch(true).required }
    it { should have_many(:pricing_actions).autosave(true).class_name('SpreeCmCommissioner::PricingAction').dependent(:destroy) }
    it { should have_many(:applied_pricing_models).class_name('SpreeCmCommissioner::AppliedPricingModel').dependent(:restrict_with_error) }
  end
end
