require 'spec_helper'

RSpec.describe Spree::Vendor, type: :model do
  describe 'associations' do
    it { should have_one(:logo).class_name('SpreeCmCommissioner::VendorLogo').dependent(:destroy) }
    it { should have_many(:photos).class_name('SpreeCmCommissioner::VendorPhoto').dependent(:destroy) }
    it { should have_many(:option_values).class_name('Spree::OptionValue').through(:products) }
  end
end