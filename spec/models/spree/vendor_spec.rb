require 'spec_helper'

RSpec.describe Spree::Vendor, type: :model do
  describe 'associations' do
    it { should have_one(:logo).class_name('SpreeCmCommissioner::VendorLogo').dependent(:destroy) }
    it { should have_many(:photos).class_name('SpreeCmCommissioner::VendorPhoto').dependent(:destroy) }
    it { should have_many(:option_values).class_name('Spree::OptionValue').through(:products) }
  end

  describe 'searchkick' do
    it 'has searchkick_index' do
      expect(described_class.searchkick_index).to be_a(Searchkick::Index)
    end

    it 'has .search method' do
      expect(described_class).to respond_to(:search)
    end

    context '#search_data' do
      let(:vendor) { described_class.new }
      let(:subject) { vendor.search_data }

      it 'includes required fields' do
        expect(subject.keys).to eq [:id, :name, :slug, :active, :min_price, :max_price, :created_at, :updated_at, :presentation]
      end
    end
  end
end