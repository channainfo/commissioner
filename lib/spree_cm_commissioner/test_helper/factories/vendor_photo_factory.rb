FactoryBot.define do
  factory :cm_vendor_photo, class: SpreeCmCommissioner::VendorPhoto do
    attachment { Rack::Test::UploadedFile.new(SpreeMultiVendor::Engine.root.join('spec', 'fixtures', 'thinking-cat.jpg'), 'image/jpeg') }
  end
end
