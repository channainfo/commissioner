require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorPlace, type: :model do
  describe 'associations' do
    it { should belong_to(:vendor).class_name('Spree::Vendor') }
    it { should belong_to(:place).class_name('SpreeCmCommissioner::Place') }
  end
end
