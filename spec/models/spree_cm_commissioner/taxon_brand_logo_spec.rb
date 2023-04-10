require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TaxonBrandLogo, type: :model do
  describe 'validations' do
    let(:txt) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'text-file.txt'), 'text/html') }
    let(:png) { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/*') }

    context 'taxon_brand_logo' do
      it 'validates attachment present' do
        taxon_brand_logo = build(:cm_taxon_brand_logo, attachment: nil)

        expect(taxon_brand_logo.save).to be false
        expect(taxon_brand_logo.errors.messages[:attachment]).to eq ["can't be blank"]
      end

      it 'validates invalid attachment type' do
        taxon_brand_logo = build(:cm_taxon_brand_logo, attachment: txt)

        expect(taxon_brand_logo.save).to be false
        expect(taxon_brand_logo.errors.messages[:attachment]).to eq ["has an invalid content type"]
      end

      it 'validates valid attachment type' do
        taxon_brand_logo = build(:cm_taxon_brand_logo, attachment: png)

        expect(taxon_brand_logo.save).to be true
      end
    end
  end
end
