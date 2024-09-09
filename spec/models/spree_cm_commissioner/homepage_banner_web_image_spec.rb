require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageBannerWebImage, type: :model do
  describe 'validations' do
    let(:txt) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'text-file.txt'), 'text/html') }
    let(:png) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/*') }

    context 'web_image' do
      it 'validates attachment present' do
        web_image = build(:cm_banner_web_image, attachment: nil)

        expect(web_image.save).to be false
        expect(web_image.errors.messages[:attachment]).to eq ["can't be blank"]
      end

      it 'validates invalid attachment type' do
        web_image = build(:cm_banner_web_image, attachment: txt)

        expect(web_image.save).to be false
        expect(web_image.errors.messages[:attachment]).to eq ["has an invalid content type"]
      end

      it 'validates valid attachment type' do
        web_image = build(:cm_banner_web_image, attachment: png)

        expect(web_image.save).to be true
      end
    end
  end
end
