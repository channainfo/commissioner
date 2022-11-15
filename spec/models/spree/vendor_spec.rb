require 'spec_helper'

RSpec.describe Spree::Vendor, type: :model do
  describe 'associations' do
    it { should have_one(:logo).class_name('SpreeCmCommissioner::VendorLogo').dependent(:destroy) }
  end
end