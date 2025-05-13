FactoryBot.define do
  factory :cm_taxon_home_banner, class: SpreeCmCommissioner::TaxonHomeBanner do
    attachment { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/jpeg') }
  end
end