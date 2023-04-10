require 'spec_helper'

RSpec.describe SpreeCmCommissioner::HomepageBannerAppImage, type: :model do
  describe 'validations' do
    let(:txt) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'text-file.txt'), 'text/html') }
    let(:gif) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.gif'), 'image/*') }

    context 'app_image' do
      it 'validates attachment present' do
        app_image = build(:cm_banner_app_image, attachment: nil)

        expect(app_image.save).to be false
        expect(app_image.errors.messages[:attachment]).to eq ["can't be blank"]
      end

      it 'validates invalid attachment type' do
        app_image = build(:cm_banner_app_image, attachment: txt)

        expect(app_image.save).to be false
        expect(app_image.errors.messages[:attachment]).to eq ["has an invalid content type"]
      end

      it 'validates valid attachment type' do
        app_image = build(:cm_banner_app_image, attachment: gif)

        expect(app_image.save).to be true
      end
    end
  end
end
