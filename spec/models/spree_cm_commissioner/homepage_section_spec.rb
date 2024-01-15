require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageSection, type: :model do
  describe 'associations' do
    it { should have_many(:homepage_section_relatables).inverse_of(:homepage_section).dependent(:destroy) }
  end

  describe '#active' do
    it 'should return active sections order by position' do
      position_1 = create(:cm_homepage_section, position: 1, active: false)
      position_3 = create(:cm_homepage_section, position: 3, active: true)
      position_2 = create(:cm_homepage_section, position: 2, active: true)
      position_4 = create(:cm_homepage_section, position: 4, active: true)

      expect(described_class.active.to_a).to eq [position_2, position_3, position_4]
    end
  end
end
