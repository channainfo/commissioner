require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Place, type: :model do

  describe 'nested set behavior' do
    let!(:root_place)    { create(:cm_place, name: 'Cambodia') }
    let!(:child_place)   { create(:cm_place, parent: root_place, name: 'Phnom Penh') }
    let!(:leaf_place)    { create(:cm_place, parent: child_place, name: 'Tuol Tompoung') }

    before do
      SpreeCmCommissioner::Place.rebuild!
      root_place.reload
      child_place.reload
      leaf_place.reload
    end

    it 'sets the parent-child relationship correctly' do
      expect(child_place.parent).to eq(root_place)
      expect(root_place.children).to include(child_place)
      expect(child_place.children).to include(leaf_place)
    end

    it 'can access ancestors and descendants' do
      expect(leaf_place.ancestors).to match_array([root_place, child_place])
      expect(root_place.descendants).to match_array([child_place, leaf_place])
    end

    it 'knows if it is a root or leaf node' do
      expect(root_place.root?).to be true
      expect(leaf_place.leaf?).to be true
    end

    it 'orders children based on lft' do
      sibling1 = create(:cm_place, name: 'Battambang', parent: root_place)
      sibling2 = create(:cm_place, name: 'Siem Reap', parent: root_place)
      expect(root_place.children).to eq([child_place, sibling1, sibling2])
    end

    it 'builds the nested tree correctly' do
      expect(root_place.children).to include(child_place)
      expect(child_place.parent).to eq(root_place)
      expect(leaf_place.ancestors).to match_array([root_place, child_place])
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:nearby_places).class_name('SpreeCmCommissioner::VendorPlace').dependent(:destroy) }
    it { is_expected.to have_many(:vendors).class_name('Spree::Vendor').through(:nearby_places) }

    it { is_expected.to have_many(:product_places).class_name('SpreeCmCommissioner::ProductPlace').dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:product_places) }
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_presence_of(:lat) }
    it { is_expected.to validate_presence_of(:lon) }
  end
end
