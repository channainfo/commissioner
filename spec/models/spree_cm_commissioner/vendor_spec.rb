require 'spec_helper'

RSpec.describe Spree::Vendor, type: :model do
  describe 'associations' do
    it { should have_many(:photos).dependent(:destroy).class_name('SpreeCmCommissioner::VendorPhoto') }
    it { should have_many(:option_values).through(:products) }
    it { should have_many(:vendor_option_types).class_name('SpreeCmCommissioner::VendorOptionType') }
    it { should have_many(:option_value_vendors).class_name('SpreeCmCommissioner::OptionValueVendor') }
    it { should have_many(:option_types).through(:vendor_option_types) }
    it { should have_many(:nearby_places).dependent(:destroy).class_name('SpreeCmCommissioner::VendorPlace') }

    it { should have_many(:promoted_option_types).through(:vendor_option_types).source(:option_type) }
    it { should have_many(:promoted_option_values).through(:option_value_vendors).source(:option_value) }

    it { should have_many(:vendor_kind_option_types).through(:vendor_option_types).source(:option_type) }
    it { should have_many(:vendor_kind_option_values).through(:option_value_vendors).source(:option_value) }

    it { should have_many(:places).through(:nearby_places).source(:place).class_name('SpreeCmCommissioner::Place') }
    it { should have_one(:logo).dependent(:destroy).class_name('SpreeCmCommissioner::VendorLogo') }
    it { should have_many(:service_calendars).dependent(:destroy).class_name('SpreeCmCommissioner::ServiceCalendar') }
  end
end
