require 'spec_helper'
require 'cancan/matchers'

RSpec.describe SpreeCmCommissioner::CheckInAbility, type: :model do
  let(:operator_user) { create(:user) }
  let(:organizer_user) { create(:user) }
  let(:guest_user) { create(:user) }

  before do
    operator_user.spree_roles << Spree::Role.find_or_create_by(name: 'operator')
    organizer_user.spree_roles << Spree::Role.find_or_create_by(name: 'organizer')
  end

  context "when user is an operator" do
    let(:ability) { SpreeCmCommissioner::CheckInAbility.new(operator_user) }

    it "allows the operator to manage CheckIn" do
      expect(ability.can?(:manage, SpreeCmCommissioner::CheckIn)).to be(true)
    end

    it "does not allow the operator to manage Guest" do
      expect(ability.can?(:manage,SpreeCmCommissioner::Guest)).to be(false)
    end
  end

  context "when user is an organizer" do
    let(:ability) { SpreeCmCommissioner::CheckInAbility.new(organizer_user) }

    it "allows the organizer to manage CheckIn" do
      expect(ability.can?(:manage, SpreeCmCommissioner::CheckIn)).to be(true)
    end

    it "allows the organizer to manage Guest" do
      expect(ability.can?(:manage, SpreeCmCommissioner::Guest)).to be(true)
    end
  end

  context "when user is a guest" do
    let(:ability) { SpreeCmCommissioner::CheckInAbility.new(guest_user) }

    it "does not allow the guest to manage CheckIn" do
      expect(ability.can?(:manage, SpreeCmCommissioner::CheckIn)).to be(false)
    end

    it "does not allow the guest to manage Guest" do
      expect(ability.can?(:manage,SpreeCmCommissioner::Guest)).to be(false)
    end
  end
end
