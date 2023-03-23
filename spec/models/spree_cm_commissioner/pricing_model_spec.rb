require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingModel, type: :model do
  describe 'constants' do
    it 'return exact rules' do
      expect(described_class::RULES).to match_array [
        SpreeCmCommissioner::PricingModel::Rules::FixedDate
      ]
    end

    it 'return exact actions' do
      expect(described_class::ACTIONS).to match_array [
        SpreeCmCommissioner::PricingModel::Actions::CreateListingPriceAdjustment
      ]
    end
  end
end