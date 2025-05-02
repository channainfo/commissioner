require 'spec_helper'

RSpec.describe SpreeCmCommissioner::EnsureCorrectProductType do
  let!(:product) { create(:cm_product, product_type: :ecommerce) }
  let!(:variant) { create(:cm_variant, product: product, product_type: :ecommerce, pregenerate_inventory_items: false) }
  let!(:inventory_item) { create(:cm_inventory_item, variant: variant, product_type: :ecommerce) }
  let!(:line_item) { create(:line_item, product_type: :ecommerce, variant: variant) }

  before do
    variant.update_column(:product_type, :service)
    inventory_item.update_column(:product_type, :transit)
    line_item.update_column(:product_type, nil)
  end

  describe '.call' do
    it 'find all invalid product_type associations & update to correct product_type' do
      expect(product.reload.product_type).to eq 'ecommerce'
      expect(variant.reload.product_type).to eq 'service'
      expect(inventory_item.reload.product_type).to eq 'transit'
      expect(line_item.reload.product_type).to eq nil

      described_class.call

      expect(product.reload.product_type).to eq 'ecommerce'
      expect(variant.reload.product_type).to eq 'ecommerce'
      expect(inventory_item.reload.product_type).to eq 'ecommerce'
      expect(line_item.reload.product_type).to eq 'ecommerce'
    end
  end
end
