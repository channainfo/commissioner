FactoryBot.define do
  factory :cm_homepage_section, class: SpreeCmCommissioner::HomepageSection do
    title { FFaker::Name.unique.name }
    description { |e| "Description for #{e.title}" }
    section_type { 'general' }
    active { true }

    # position is defaultly set by act_as_list
    transient do
      position { nil }
    end

    after(:create) do |section, evaluator|
      if evaluator.position.present?
        section.update_column(:position, evaluator.position)
      end
    end
  end
end
