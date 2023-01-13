require 'spec_helper'

RSpec.describe Spree::LineItem, type: :model do
  describe '#callback before_save' do
    let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
    let!(:vendor) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', state_id: phnom_penh.id) }
    let!(:variant) { vendor.variants.first }
    let!(:order) { create(:order) }
    let(:line_item) { order.line_items.build(variant_id: variant.id) }

    context '#update_vendor_id' do
      it 'should add vendor_id to line_item' do
        subject { line_item.save }
        expect(line_item.vendor_id).to eq vendor.id
      end
    end
  end
end