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
end
