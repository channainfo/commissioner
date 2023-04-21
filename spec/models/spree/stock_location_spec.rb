  require 'spec_helper'

  RSpec.describe Spree::StockLocation, type: :model do
    describe '#callback after_commit' do
      let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
      let(:siem_reap) { create(:state, name: 'Siem Reap') }
      let!(:vendor) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', state_id: phnom_penh.id) }
      let!(:stock_location) { vendor.stock_locations.first }

      context '#update_vendor_location' do
        it 'should update vendor state_id' do
          stock_location.update(state_id: siem_reap.id)
          expect(vendor.state_id).to eq siem_reap.id
        end
      end
    end
  end