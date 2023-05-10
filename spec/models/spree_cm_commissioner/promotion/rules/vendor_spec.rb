require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Promotion::Rules::Vendor do
  describe '#eligible?' do
    let(:product) { create(:cm_accommodation_product, price: BigDecimal('10.0'), permanent_stock: 4) }
    let(:order) { create(:order) }
    let!(:line_item) { create(:line_item, order: order, price: BigDecimal('10.0'), quantity: 2, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }

    it 'eligible when vendor match to rule' do
      subject = described_class.new(vendor: product.vendor)
      expect(subject.eligible?(order)).to be true
    end

    it 'not eligible when vendor does not match to rule' do
      subject = described_class.new(vendor: create(:cm_vendor))
      expect(subject.eligible?(order)).to be false
    end
  end
end