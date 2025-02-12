require 'spec_helper'

RSpec.describe Spree::Taxonomy, type: :model do
  describe '.place' do
    context "when there is place taxonomy" do
      let!(:place_taxonomy) { create(:taxonomy, name: 'Place', kind: 'transit') }
      it "should return the existed place taxonomy" do
        expect(Spree::Taxonomy.place).to eq(place_taxonomy)
      end
    end
    context "When Place taxonomy does not exist" do
      it "create and returns a new Place taxonomy" do
        expect { Spree::Taxonomy.place }.to change { Spree::Taxonomy.count }.by(1)
        expect(Spree::Taxonomy.last.name).to eq('Place')
      end
    end
  end
end
