FactoryBot.define do
  factory :transit_place, class: Spree::Taxon do
    transient do
      taxonomy  { Spree::Taxonomy.place}
    end
    parent{ taxonomy.root }
  end
end
