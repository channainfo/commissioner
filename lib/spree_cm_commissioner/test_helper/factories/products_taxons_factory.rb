FactoryBot::define do
  factory :cm_product_taxon, class: Spree::Classification do
    product { create(:cm_product) }
    taxon { Spree::Taxon.create(parent_id: 1,name: 'Event') }
    total_count { 0 }
  end
end
