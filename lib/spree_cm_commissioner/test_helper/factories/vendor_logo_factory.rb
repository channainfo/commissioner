FactoryBot.define do
  factory :cm_vendor_logo, class: SpreeCmCommissioner::VendorLogo do
    attachment { Rack::Test::UploadedFile.new(SpreeMultiVendor::Engine.root.join('spec', 'fixtures', 'thinking-cat.jpg'), 'image/jpeg') }
  end
end
