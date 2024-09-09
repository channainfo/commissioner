require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Place, type: :model do
  describe 'associations' do
    it { should have_many(:nearby_places).class_name('SpreeCmCommissioner::VendorPlace').dependent(:destroy) }
    it { should have_many(:vendors).class_name('Spree::Vendor').through(:nearby_places) }

    it { should have_many(:product_places).class_name('SpreeCmCommissioner::ProductPlace').dependent(:destroy) }
    it { should have_many(:products).through(:product_places) }
  end

  describe 'validation' do
    it { should validate_presence_of(:reference) }
    it { should validate_presence_of(:lat) }
    it { should validate_presence_of(:lon) }
  end
end
