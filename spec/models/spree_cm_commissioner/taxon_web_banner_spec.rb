require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TaxonWebBanner, type: :model do
  describe 'validations' do
    let(:txt) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'text-file.txt'), 'text/html') }
    let(:png) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/*') }

    context 'taxon_web_banner' do
      it 'validates attachment present' do
        taxon_web_banner = build(:cm_taxon_web_banner, attachment: nil)

        expect(taxon_web_banner.save).to be false
        expect(taxon_web_banner.errors.messages[:attachment]).to eq ["can't be blank"]
      end

      it 'validates invalid attachment type' do
        taxon_web_banner = build(:cm_taxon_web_banner, attachment: txt)

        expect(taxon_web_banner.save).to be false
        expect(taxon_web_banner.errors.messages[:attachment]).to eq ["has an invalid content type"]
      end

      it 'validates valid attachment type' do
        taxon_web_banner = build(:cm_taxon_web_banner, attachment: png)

        expect(taxon_web_banner.save).to be true
      end
    end
  end
end
