require 'spec_helper'

RSpec.describe Spree::Variant, type: :model do
  describe 'callbacks' do
    context '#after_commit' do
      let(:vendor) { create(:active_vendor, name: 'Angkor Hotel', min_price: 10, max_price: 30) }
      let(:state) { create(:state, name: 'Siemreap') }
      let!(:option_type) { create(:option_type, name: 'location', presentation: 'Location', attr_type: 'state_selection') }
      let!(:option_value) { create(:option_value, option_type: option_type, presentation: state.id) }
      let!(:stock_location) { vendor.stock_locations.first.update(state: state) }
      let!(:product1) { create(:base_product, name: 'Bedroom 1', vendor: vendor, price: 10 ) }
      let!(:product2) { create(:base_product, name: 'Bedroom 2', vendor: vendor, price: 20 ) }
      let!(:product3) { create(:base_product, name: 'Bedroom 3', vendor: vendor, price: 30 ) }

      it 'updates vendor min_price' do
        subject { product1.update(price: 5) }
        expect(vendor.min_price).to eq product1.price
      end

      it 'updates vendor max_price' do
        subject { product3.update(price: 35) }
        expect(vendor.max_price).to eq product3.price
      end

      it 'should not update vendor min_price' do
        subject { product1.update(price: 15) }
        expect(vendor.min_price).to eq product1.price
      end

      it 'should not update vendor max_price' do
        subject { product3.update(price: 25) }
        expect(vendor.max_price).to eq product3.price
      end
    end
  end
end