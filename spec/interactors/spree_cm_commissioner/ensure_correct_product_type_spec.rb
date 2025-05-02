require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EnsureCorrectProductType do
  let!(:product) { create(:cm_product, product_type: :transit) }
  let!(:variant) { create(:cm_variant, product: product, product_type: :ecommerce) }
  let!(:line_item) { create(:line_item, product_type: :service, variant: variant) }
  let!(:inventory_item) { create(:cm_inventory_item, variant: variant, product_type: :accommodation) }

  describe '.call' do
    it 'find all invalid product_type associations & update to correct product_type' do
      described_class.call

      expect(product.reload.product_type).to eq 'transit'
      expect(variant.reload.product_type).to eq 'transit'
      expect(line_item.reload.product_type).to eq 'transit'
      expect(inventory_item.reload.product_type).to eq 'transit'
    end
  end
end
