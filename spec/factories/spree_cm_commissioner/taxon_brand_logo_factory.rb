FactoryBot.define do
  factory :cm_taxon_brand_logo, class: SpreeCmCommissioner::TaxonBrandLogo do
    attachment { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/jpeg') }
  end
end