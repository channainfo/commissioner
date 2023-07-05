require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageBackground, type: :model do
  describe 'associations' do
    it { should have_one(:app_image).class_name('SpreeCmCommissioner::HomepageBackgroundAppImage').dependent(:destroy) }
    it { should have_one(:web_image).class_name('SpreeCmCommissioner::HomepageBackgroundWebImage').dependent(:destroy) }
  end
  
  describe '.active' do
    it 'return only active backgrounds' do
      background1 = create(:cm_homepage_background, active: true)
      background2 = create(:cm_homepage_background, active: false)
      
      expect(described_class.active.size).to eq 1
      expect(described_class.active.first).to eq background1
    end
  end
  
  describe 'validations' do
    let(:background) { build(:cm_homepage_background) }
    let(:txt) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'text-file.txt'), 'text/html') }
    
    context 'app_image' do
      it 'validates attachment present' do
        app_image = build(:cm_background_app_image, attachment: nil)
        background.app_image = app_image
        
        expect(background.save).to be false
        expect(background.app_image.errors.messages[:attachment]).to eq ["can't be blank"]
      end
      
      it 'validates attachment type' do
        app_image = build(:cm_background_app_image, attachment: txt)
        background.app_image = app_image
        
        expect(background.save).to be false
        expect(background.app_image.errors.messages[:attachment]).to eq ["has an invalid content type"]
      end
    end
    
    context 'web_image' do
      it 'validates attachment present' do
        web_image = build(:cm_background_web_image, attachment: nil)
        background.web_image = web_image
        
        expect(background.save).to be false
        expect(background.web_image.errors.messages[:attachment]).to eq ["can't be blank"]
      end
      
      it 'validates attachment type' do
        web_image = build(:cm_background_web_image, attachment: txt)
        background.web_image = web_image
        
        expect(background.save).to be false
        expect(background.web_image.errors.messages[:attachment]).to eq ["has an invalid content type"]
      end
    end
  end
  
  describe '#toggle_status' do
    context 'when active is false' do
      it 'return true' do
        background = create(:cm_homepage_background, active: false)
        background.toggle_status
        
        expect(background.active).to eq true
      end
    end
    
    context 'when active is true' do
      it 'return false' do
        background = create(:cm_homepage_background, active: true)
        background.toggle_status
        
        expect(background.active).to eq false
      end
    end
  end
end
