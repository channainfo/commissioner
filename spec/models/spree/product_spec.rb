require 'spec_helper'

RSpec.describe Spree::Product, type: :model do
  describe 'associations' do
    it { should have_many(:prices_including_master).class_name('Spree::Price').through(:variants_including_master) }
    it { should have_many(:option_values).through(:option_types) }
    it { should have_many(:variant_kind_option_types).through(:product_option_types) }
    it { should have_many(:product_kind_option_types).through(:product_option_types) }
    it { should have_many(:promoted_option_types).through(:product_option_types) }
  end

  describe 'attributes' do
    it { should define_enum_for :product_type }
    it { expect(described_class.product_types.keys).to match(SpreeCmCommissioner::ProductType::PRODUCT_TYPES.map(&:to_s)) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:commission_rate).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil }
  end

  describe 'callback: after_update' do
    describe '#update_variants_vendor_id' do
      let(:variant1) { build(:variant) }
      let(:variant2) { build(:variant) }

      let!(:vendor1) { create(:vendor) }
      let!(:vendor2) { create(:vendor) }

      let!(:product) { create(:product, variants: [variant1, variant2], vendor: vendor1) }

      it 'update variants including master to new vendor' do
        expect(variant1.vendor_id).to eq vendor1.id
        expect(variant2.vendor_id).to eq vendor1.id

        product.update!(vendor: vendor2)

        expect(product.master.reload.vendor_id).to eq vendor2.id
        expect(variant1.reload.vendor_id).to eq vendor2.id
        expect(variant2.reload.vendor_id).to eq vendor2.id
      end
    end
  end

  describe 'scope' do
    let(:vendor) { create(:active_vendor, name: 'Angkor Hotel') }
    let(:state) { create(:state, name: 'Siemreap') }
    let!(:option_type) { create(:option_type, name: 'location', presentation: 'Location', attr_type: 'state_selection') }
    let!(:option_value) { create(:option_value, option_type: option_type, name: state.id) }
    let!(:stock_location) { vendor.stock_locations.first.update(state: state) }

    context 'vendor with many products' do
      let!(:product1) { create(:product_with_option_types, name: 'Bedroom 1', vendor: vendor, price: 10) }
      let!(:product2) { create(:product_with_option_types, name: 'Bedroom 2', vendor: vendor, price: 20 ) }
      let!(:product3) { create(:product_with_option_types, name: 'Bedroom 3', vendor: vendor, price: 30 ) }
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
      let!(:product1) { create(:base_product, name: 'Bedroom 1', vendor: vendor, price: 10) }

      it '.min_price' do
        expect(Spree::Product.min_price(vendor)).to eq product1.price
      end

      it '.max_price' do
        expect(Spree::Product.max_price(vendor)).to eq product1.price
      end
    end

    context 'vendor with no product' do
      it '.min_price' do
        expect(Spree::Product.min_price(vendor)).to eq 0
      end

      it '.max_price' do
        expect(Spree::Product.max_price(vendor)).to eq 0
      end
    end
  end
end