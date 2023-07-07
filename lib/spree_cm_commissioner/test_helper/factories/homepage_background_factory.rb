FactoryBot.define do
  factory :cm_homepage_background, class: SpreeCmCommissioner::HomepageBackground do
    title         {FFaker::Name.unique.name}
    active        {true}
    
    trait :with_app_image do
      app_image { create(:cm_background_app_image) }
    end
    
    trait :with_web_image do
      web_image { create(:cm_background_web_image) }
    end
    
    trait :with_app_web_image do
      web_image { create(:cm_background_web_image) }
      app_image { create(:cm_background_app_image) }
    end
  end
end
