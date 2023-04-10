require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageBanner, type: :model do
  describe 'associations' do
    it { should have_one(:app_image).class_name('SpreeCmCommissioner::HomepageBannerAppImage').dependent(:destroy) }
    it { should have_one(:web_image).class_name('SpreeCmCommissioner::HomepageBannerWebImage').dependent(:destroy) }
  end

  describe '.active' do
    it 'return only active banners' do
      banner1 = create(:cm_homepage_banner, active: true)
      banner2 = create(:cm_homepage_banner, active: false)

      expect(described_class.active.size).to eq 1
      expect(described_class.active.first).to eq banner1
    end
  end

  describe 'validations' do
    let(:banner) { build(:cm_homepage_banner) }
    let(:txt) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'text-file.txt'), 'text/html') }

    context 'app_image' do
      it 'validates attachment present' do
        app_image = build(:cm_banner_app_image, attachment: nil)
        banner.app_image = app_image

        expect(banner.save).to be false
        expect(banner.app_image.errors.messages[:attachment]).to eq ["can't be blank"]
      end

      it 'validates attachment type' do
        app_image = build(:cm_banner_app_image, attachment: txt)
        banner.app_image = app_image

        expect(banner.save).to be false
        expect(banner.app_image.errors.messages[:attachment]).to eq ["has an invalid content type"]
      end
    end

    context 'web_image' do
      it 'validates attachment present' do
        web_image = build(:cm_banner_web_image, attachment: nil)
        banner.web_image = web_image

        expect(banner.save).to be false
        expect(banner.web_image.errors.messages[:attachment]).to eq ["can't be blank"]
      end

      it 'validates attachment type' do
        web_image = build(:cm_banner_web_image, attachment: txt)
        banner.web_image = web_image

        expect(banner.save).to be false
        expect(banner.web_image.errors.messages[:attachment]).to eq ["has an invalid content type"]
      end
    end
  end

  describe '#toggle_status' do
    context 'when active is false' do
      it 'return true' do
        banner = create(:cm_homepage_banner, active: false)
        banner.toggle_status

        expect(banner.active).to eq true
      end
    end

    context 'when active is true' do
      it 'return false' do
        banner = create(:cm_homepage_banner, active: true)
        banner.toggle_status

        expect(banner.active).to eq false
      end
    end
  end
end
