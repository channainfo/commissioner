require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorUpdater do
  let(:accommodation) { Spree::Product::product_types[:accommodation] }
  let(:service) { Spree::Product::product_types[:ecommerce] }

  let(:vendor) { create(:active_vendor, name: 'Angkor Hotel', primary_product_type: accommodation ) }
  let(:state) { create(:state, name: 'Siemreap') }
  let!(:option_type) { create(:option_type, name: 'location', presentation: 'Location', attr_type: 'state_selection') }
  let!(:option_value) { create(:option_value, option_type: option_type, presentation: state.id) }
  let!(:stock_location) { vendor.stock_locations.first.update(state: state) }
  let(:shipping_category) { create(:shipping_category, name: 'Digital') }

  describe '.call' do
    context 'without product variants' do
      let!(:product1) { create(:product, name: 'Bedroom 1', vendor: vendor, product_type: accommodation, price: 10, shipping_category: shipping_category ) }
      let!(:product3) { create(:product, name: 'Bedroom 3', vendor: vendor, product_type: accommodation, price: 20, shipping_category: shipping_category ) }

      it 'update min and max price' do
        context = SpreeCmCommissioner::VendorUpdater.call(vendor: vendor)

        vendor.reload

        expect(vendor.min_price).to eq product1.price
        expect(vendor.max_price).to eq product3.price
      end

      it 'update total inventory' do
        context = SpreeCmCommissioner::VendorUpdater.call(vendor: vendor)

        vendor.reload

        expect(vendor.total_inventory).to eq 2 # default master_variant has 1 item each by default
      end
    end

    context 'with product variants' do
      it 'update vendor min and max price if [variant product_type] is primary_product_type' do
        product1 = create(:product, name: 'Bedroom', vendor: vendor, product_type: accommodation, price: 13, shipping_category: shipping_category )
        product2 = create(:product, name: 'Breakfast', vendor: vendor, product_type: service, price: 14, shipping_category: shipping_category )

        variant1 = create(:base_variant, product: product1, price: 10 )
        variant2 = create(:base_variant, product: product1, price: 20 )
        variant3 = create(:base_variant, product: product2, price: 30 )

        context = SpreeCmCommissioner::VendorUpdater.call(vendor: vendor)
        vendor.reload

        expect(vendor.min_price).to eq 10
        expect(vendor.max_price).to eq 20

        expect(vendor.min_price).to eq variant1.price
        expect(vendor.max_price).to eq variant2.price
      end

      it 'update min and max price even base on master variant price' do
        product = create(:product, name: 'Breakfast', vendor: vendor, product_type: accommodation, price: 5, shipping_category: shipping_category )

        variant1 = create(:base_variant, product: product, price: 10 )
        variant2 = create(:base_variant, product: product, price: 30 )

        context = SpreeCmCommissioner::VendorUpdater.call(vendor: vendor)
        vendor.reload

        expect(vendor.min_price).to eq 5
        expect(vendor.max_price).to eq 30

        expect(vendor.min_price).to eq product.master.price
        expect(vendor.max_price).to eq variant2.price
      end

      it "return min, max price zero if vendor couldn't find primary_product_type variants" do
        product = create(:product, name: 'Breakfast', vendor: vendor, product_type: service, price: 5, shipping_category: shipping_category )

        context = SpreeCmCommissioner::VendorUpdater.call(vendor: vendor)
        vendor.reload

        expect(vendor.min_price).to eq 0
        expect(vendor.max_price).to eq 0
      end
    end
  end
end
