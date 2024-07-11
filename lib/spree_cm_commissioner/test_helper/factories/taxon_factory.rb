FactoryBot.define do
  factory :cm_taxon_event_section, parent: :taxon do
    kind { :event }
    sequence(:name) { |n| "Ticket Type #{n}" }

    after(:build) do |taxon, evaluator|
      taxon.taxonomy.update(kind: taxon.kind)
    end
  end

  factory :cm_taxon_event, parent: :taxon do
    kind { :event }
    name { 'TedX' }

    transient do
      sections_count { 2 }
      products_count_per_section { 2 }
    end

    after(:create) do |taxon, evaluator|
      if evaluator.sections_count > 0
        taxon.children = create_list(:cm_taxon_event_section, evaluator.sections_count, parent: taxon, taxonomy: taxon.taxonomy)

        if evaluator.products_count_per_section > 0
          taxon.children.each do |section|
            section.products = create_list(:cm_product, evaluator.products_count_per_section, taxons: [section])
          end
        end
      end
    end
  end
end
