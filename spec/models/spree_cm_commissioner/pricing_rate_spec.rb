require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingRate, type: :model do
  describe 'associations' do
    it { should belong_to(:rateable).inverse_of(:pricing_rates).required }
    it { should have_many(:applied_pricing_rate).class_name('SpreeCmCommissioner::AppliedPricingRate').dependent(:restrict_with_error) }
    it { should have_one(:default_price).class_name('Spree::Price') }
  end
end
