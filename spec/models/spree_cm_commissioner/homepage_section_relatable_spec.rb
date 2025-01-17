require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageSectionRelatable, type: :model do
  describe '.active' do
    let(:section) { create(:cm_homepage_section) }

    it 'should return active relatables ordered by position' do
      position_1 = create(:cm_homepage_section_relatable, homepage_section: section, position: 1, available_on: nil, discontinue_on: nil)
      position_3 = create(:cm_homepage_section_relatable, homepage_section: section, position: 3, available_on: 1.day.ago, discontinue_on: 1.day.from_now)
      position_2 = create(:cm_homepage_section_relatable, homepage_section: section, position: 2, available_on: 1.day.ago, discontinue_on: nil)
      position_4 = create(:cm_homepage_section_relatable, homepage_section: section, position: 4, available_on: 2.days.ago, discontinue_on: 1.day.ago)
      expect(described_class.active.to_a).to eq [position_1, position_2, position_3]
    end
  end

  describe '#update_homepage_section' do
    it 'should update the homepage_section updated_at when relatable is updated' do
      homepage_section = create(:cm_homepage_section)
      relatable = create(:cm_homepage_section_relatable, homepage_section: homepage_section, available_on: nil, discontinue_on: nil)
      relatable.update(available_on: 1.day.from_now)
      expect(homepage_section.reload.updated_at.to_i).to eq relatable.updated_at.to_i
    end
  end
end