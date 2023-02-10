require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorPlace, type: :model do
  describe 'associations' do
    it { should belong_to(:vendor).class_name('Spree::Vendor').dependent(:destroy) }
    it { should belong_to(:place).class_name('SpreeCmCommissioner::Place').dependent(:destroy)}
  end
end
