FactoryBot.define do
  factory :cm_background_web_image, class: SpreeCmCommissioner::HomepageBackgroundWebImage do
    attachment {Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/jpeg')}
  end
end
