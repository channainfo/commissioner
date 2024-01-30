require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageSectionRelatable, type: :model do
  describe 'associations' do
    it { should belong_to(:homepage_section).inverse_of(:homepage_section_relatables).dependent(:destroy) }
    it { should belong_to(:relatable).inverse_of(:homepage_section_relatables).dependent(:destroy) }
  end

  describe '#active' do
    let(:section) { create(:cm_homepage_section) }

    it 'should return active sections order by position' do
      position_1 = create(:cm_homepage_section_relatable, homepage_section: section, position: 1, active: false)
      position_3 = create(:cm_homepage_section_relatable, homepage_section: section, position: 3, active: true)
      position_2 = create(:cm_homepage_section_relatable, homepage_section: section, position: 2, active: true)
      position_4 = create(:cm_homepage_section_relatable, homepage_section: section, position: 4, active: true)

      expect(described_class.active.to_a).to eq [position_2, position_3, position_4]
    end
  end

  describe '#update_homepage_section' do
    it 'should update the homepage_section updated_at when relatable is updated' do
      homepage_section = create(:cm_homepage_section)
      relatable = create(:cm_homepage_section_relatable, homepage_section: homepage_section, active: true)

      relatable.update(active: false)

      expect(homepage_section.updated_at.to_i).to eq relatable.updated_at.to_i
    end
  end
end
