require 'spec_helper'

RSpec.describe Spree::Ability, type: :model do
  let(:user) { create(:user) }
  let(:ability) { Spree::Ability.new(user) }

  describe "abilities_to_register" do
    it "removes Spree::VendorAbility from the abilities list" do
      expect(ability.class.abilities).not_to include(Spree::VendorAbility)
    end

    it "adds SpreeCmCommissioner::CheckInAbility to the abilities list" do
      expect(ability.class.abilities).to include(SpreeCmCommissioner::CheckInAbility)
    end
  end
end
