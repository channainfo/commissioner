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

  describe '#homepage_section_relatables_count' do
    let!(:homepage_section) { create(:cm_homepage_section) }

    let!(:relatable_1) { create(:cm_homepage_section_relatable, homepage_section: homepage_section) }
    let!(:relatable_2) { create(:cm_homepage_section_relatable, homepage_section: homepage_section) }

    it 'should increase the count when a new homepage_section_relatable is added' do
      relatable_3 = create(:cm_homepage_section_relatable, homepage_section: homepage_section)

      expect(homepage_section.homepage_section_relatables_count).to eq 3
    end

    it 'should decrease the count when a homepage_section_relatable is destroyed' do
      relatable_2.destroy

      homepage_section.reload

      expect(homepage_section.homepage_section_relatables_count).to eq 1
    end
  end

  describe '.filter_by_segment' do
    it 'should return sections with the given segment' do
      general_section = create(:cm_homepage_section, segment: 1)
      ticket_section = create(:cm_homepage_section, segment: 2)
      tour_section = create(:cm_homepage_section, segment: 4)
      accommodation = create(:cm_homepage_section, segment: 8)

      expect(described_class.filter_by_segment(:general).to_a).to eq [general_section]
      expect(described_class.filter_by_segment(:ticket).to_a).to eq [ticket_section]
      expect(described_class.filter_by_segment(:tour).to_a).to eq [tour_section]
      expect(described_class.filter_by_segment(:accommodation).to_a).to eq [accommodation]
    end
  end
end
