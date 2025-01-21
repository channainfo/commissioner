FactoryBot.define do
  factory :cm_homepage_section_relatable, class: SpreeCmCommissioner::HomepageSectionRelatable do
    homepage_section { create(:cm_homepage_section) }
    relatable { create(:taxon) }
    available_on { nil }
    discontinue_on { nil }

   # position is defaultly set by act_as_list
    transient do
      position { nil }
    end

    after(:create) do |relatable, evaluator|
      if evaluator.position.present?
        relatable.update_column(:position, evaluator.position)
      end
    end

    factory :cm_product_homepage_section_relatable do
      relatable { create(:product) }
    end

    factory :cm_taxon_homepage_section_relatable do
      relatable { create(:taxon) }
    end

    factory :cm_vendor_homepage_section_relatable do
      relatable { create(:vendor) }
    end
  end
end
