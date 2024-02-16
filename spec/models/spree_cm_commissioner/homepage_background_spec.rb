require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageBackground, type: :model do
  describe 'associations' do
    it { should have_one(:app_image).class_name('SpreeCmCommissioner::HomepageBackgroundAppImage').dependent(:destroy) }
    it { should have_one(:web_image).class_name('SpreeCmCommissioner::HomepageBackgroundWebImage').dependent(:destroy) }
  end

  describe '#toggle_status' do
    context 'when active is false' do
      it 'return true' do
        background = create(:cm_homepage_background, active: false)
        background.toggle_status!

        expect(background.active).to eq true
      end
    end

    context 'when active is true' do
      it 'return false' do
        background = create(:cm_homepage_background, active: true)
        background.toggle_status!

        expect(background.active).to eq false
      end
    end
  end

  describe '.filter_by_segment' do
    it 'should return backgrounds with the given segment' do
      general_background = create(:cm_homepage_background, segment: 1)
      ticket_background = create(:cm_homepage_background, segment: 2)
      tour_background = create(:cm_homepage_background, segment: 4)
      accommodation = create(:cm_homepage_background, segment: 8)

      expect(described_class.filter_by_segment(:general).to_a).to eq [general_background]
      expect(described_class.filter_by_segment(:ticket).to_a).to eq [ticket_background]
      expect(described_class.filter_by_segment(:tour).to_a).to eq [tour_background]
      expect(described_class.filter_by_segment(:accommodation).to_a).to eq [accommodation]
    end
  end
end
