FactoryBot.define do
  factory :cm_banner_web_image, class: SpreeCmCommissioner::HomepageBannerWebImage do
    attachment { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/jpeg') }
  end
end