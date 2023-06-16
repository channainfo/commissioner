FactoryBot.define do
  factory :cm_asset, class: SpreeCmCommissioner::Asset do
    viewable_type {}
    viewable_id {}

    attachment { Rack::Test::UploadedFile.new(Spree::Core::Engine.root.join('spec', 'fixtures', 'files', 'icon_256x256.png'), 'image/*')  }
  end
end
