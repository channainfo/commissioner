require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorUpdater do
  let(:product_type) { create(:product_type, name: 'property', presentation: 'Property', enabled: true) }
  let(:vendor) { create(:active_vendor, name: 'Angkor Hotel', primary_product_type: product_type ) }
  let(:state) { create(:state, name: 'Siemreap') }
  let!(:option_type) { create(:option_type, name: 'location', presentation: 'Location', attr_type: 'state_selection') }
  let!(:option_value) { create(:option_value, option_type: option_type, presentation: state.id) }
  let!(:stock_location) { vendor.stock_locations.first.update(state: state) }
  let(:shipping_category) { create(:shipping_category, name: 'Digital') }
  let!(:product1) { create(:product, name: 'Bedroom 1', vendor: vendor, product_type: product_type, price: 10, shipping_category: shipping_category ) }
  let!(:product2) { create(:product, name: 'Bedroom 2', vendor: vendor, product_type: product_type, price: 20, shipping_category: shipping_category ) }
  let!(:product3) { create(:product, name: 'Bedroom 3', vendor: vendor, product_type: product_type, price: 30, shipping_category: shipping_category ) }

  describe '.call' do
    context 'without product variants' do
      it 'update min and max price' do
        context = SpreeCmCommissioner::VendorUpdater.call(vendor: vendor)

        vendor.reload

        expect(vendor.min_price).to eq product1.price
        expect(vendor.max_price).to eq product3.price
      end
    end

    context 'with product variants' do
      let!(:variant_product1) { create(:base_variant, product: product1, price: 8 ) }
      let!(:variant_product3) { create(:base_variant, product: product1, price: 35 ) }

      it 'update min and max price' do
        context = SpreeCmCommissioner::VendorUpdater.call(vendor: vendor)

        vendor.reload

        expect(vendor.min_price).to eq variant_product1.price
        expect(vendor.max_price).to eq variant_product3.price
      end
    end
  end
end
