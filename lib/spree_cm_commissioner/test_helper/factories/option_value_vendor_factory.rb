FactoryBot.define do
  factory :cm_option_value_vendor, class: SpreeCmCommissioner::OptionValueVendor do
    option_value { create(:option_value) }
    vendor { create(:cm_vendor) }
  end
end