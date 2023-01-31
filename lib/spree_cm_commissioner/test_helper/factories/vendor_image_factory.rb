FactoryBot.define do
  factory :cm_vendor_image, class: Spree::VendorImage do
    attachment { Rack::Test::UploadedFile.new(SpreeMultiVendor::Engine.root.join('spec', 'fixtures', 'thinking-cat.jpg'), 'image/jpeg') }
  end
end
