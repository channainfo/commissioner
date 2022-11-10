FactoryBot.define do
  factory :vendor_logo, class: Spree::VendorLogo do
    attachment { Rack::Test::UploadedFile.new(SpreeMultiVendor::Engine.root.join('spec', 'fixtures', 'thinking-cat.jpg'), 'image/jpeg') }
  end
end