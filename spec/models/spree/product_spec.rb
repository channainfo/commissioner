require 'spec_helper'

RSpec.describe Spree::Product, type: :model do
  describe 'associations' do
    it { should have_many(:prices_including_master).class_name('Spree::Price').through(:variants_including_master) }
  end

  describe 'scope' do
    context 'vendor with many products' do
      let(:vendor) { create(:active_vendor, name: 'Angkor Hotel') }
      let!(:product1) { create(:base_product, name: 'Bedroom 1', vendor: vendor, price: 10 ) }
      let!(:product2) { create(:base_product, name: 'Bedroom 2', vendor: vendor, price: 20 ) }
      let!(:product3) { create(:base_product, name: 'Bedroom 3', vendor: vendor, price: 30 ) }
      let!(:variant_product1) { create(:base_variant, product: product1, price: 8 ) }
      let!(:variant_product3) { create(:base_variant, product: product1, price: 25 ) }

      it '.min_price' do
        expect(Spree::Product.min_price(vendor)).to eq variant_product1.price
      end

      it '.max_price' do
        expect(Spree::Product.max_price(vendor)).to eq product3.price
      end
    end

    context 'vendor with 1 product' do
      let(:vendor) { create(:active_vendor, name: 'Bayond Hotel') }
      let!(:product1) { create(:base_product, name: 'Bedroom 1', vendor: vendor, price: 10 ) }

      it '.min_price' do
        expect(Spree::Product.min_price(vendor)).to eq product1.price
      end

      it '.max_price' do
        expect(Spree::Product.max_price(vendor)).to eq product1.price
      end
    end

    context 'vendor with no product' do
      let(:vendor) { create(:active_vendor, name: 'Banteay Srey Hotel') }

      it '.min_price' do
        expect(Spree::Product.min_price(vendor)).to eq 0
      end

      it '.max_price' do
        expect(Spree::Product.max_price(vendor)).to eq 0
      end
    end
  end
end