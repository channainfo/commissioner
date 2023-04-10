FactoryBot.define do
  factory :cm_homepage_banner, class: SpreeCmCommissioner::HomepageBanner do
    title         { FFaker::Name.unique.name }
    redirect_url  { FFaker::Internet.http_url }
    active        { true }

    trait :with_app_image do
      app_image { create(:cm_banner_app_image) }
    end

    trait :with_web_image do
      web_image { create(:cm_banner_web_image) }
    end

    trait :with_app_web_image do
      web_image  { create(:cm_banner_web_image) }
      app_image  { create(:cm_banner_app_image) }
    end
  end
end
