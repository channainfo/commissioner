FactoryBot.define do
  factory :cm_front_image, class: SpreeCmCommissioner::FrontImage do
    attachment { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/jpeg') }
  end
end
