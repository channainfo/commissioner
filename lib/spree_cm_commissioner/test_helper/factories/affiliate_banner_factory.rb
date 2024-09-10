FactoryBot.define do
  factory :affiliate_banner, class: SpreeCmCommissioner::AffiliateBanner do
    banner { Rack::Test::UploadedFile.new(SpreeCmCommissioner::Engine.root.join('spec', 'fixtures', 'thinking-cat.jpg'), 'image/jpeg') }
  end
end