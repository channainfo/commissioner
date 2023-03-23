require 'spec_helper'

RSpec.describe Spree::Promotion, type: :model do
  describe 'constants' do
    it 'return exact rules' do
      expect(described_class::RULES).to match_array [
        Spree::Promotion::Rules::ItemTotal,
        Spree::Promotion::Rules::Product,
        Spree::Promotion::Rules::User,
        Spree::Promotion::Rules::FirstOrder,
        Spree::Promotion::Rules::UserLoggedIn,
        Spree::Promotion::Rules::OneUsePerUser,
        Spree::Promotion::Rules::Taxon,
        Spree::Promotion::Rules::OptionValue,
        Spree::Promotion::Rules::Country
      ]
    end

    it 'return exact actions' do
      expect(described_class::ACTIONS).to match_array [
        Spree::Promotion::Actions::CreateAdjustment,
        Spree::Promotion::Actions::CreateItemAdjustments,
        Spree::Promotion::Actions::CreateLineItems,
        Spree::Promotion::Actions::FreeShipping
      ]
    end
  end
end