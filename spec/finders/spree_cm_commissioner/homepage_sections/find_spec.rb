require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageSections::Find do
  let!(:homepage_section1) { create(:cm_homepage_section) }
  let!(:homepage_section2) { create(:cm_homepage_section) }
  let!(:homepage_section3) { create(:cm_homepage_section) }
  let!(:homepage_section4) { create(:cm_homepage_section, section_type: 'ticket' ) }
  let!(:homepage_section5) { create(:cm_homepage_section, section_type: 'ticket' ) }

  describe '#execute' do
    let(:ids) { [homepage_section1.id, homepage_section2.id, homepage_section3.id, homepage_section4.id, homepage_section5.id] }
    let(:scope) { SpreeCmCommissioner::HomepageSection.where(id: ids) }

    context 'when section_type is ticket' do
      let(:ticket_scope) { scope.where(section_type: 'ticket') }

      it 'return homepage section by ticket type' do
        result = SpreeCmCommissioner::HomepageSections::Find.new(
          scope: scope,
          params: { filter: { section_type: 'ticket' } }
        ).execute

        expect(result.size).to eq ticket_scope.size
        expect(result).to eq ticket_scope
      end
    end

    context 'when section_type is excluded' do
      it 'return all homepage sections' do
        result = SpreeCmCommissioner::HomepageSections::Find.new(
          scope: scope,
          params: { filter: { section_type: 'unknown_type' } }
        ).execute

        expect(result.size).to eq scope.size
        expect(result).to eq scope
      end
    end
  end
end
