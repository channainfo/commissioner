FactoryBot.define do
  factory :cm_taxon_category_icon, class: SpreeCmCommissioner::TaxonCategoryIcon do
    attachment { Rack::Test::UploadedFile.new(SpreeMultiVendor::Engine.root.join('spec', 'fixtures', 'thinking-cat.jpg'), 'image/jpeg') }
  end
end