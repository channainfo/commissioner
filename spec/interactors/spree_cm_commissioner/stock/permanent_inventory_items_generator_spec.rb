require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator do
  let!(:permanent_product) { create(:product, product_type: :accommodation) }
  let!(:non_permanent_product) { create(:product, product_type: :ecommerce) }

  let!(:permanent_variant) { create(:cm_base_variant, is_master: false, product: permanent_product, total_inventory: 5) }
  let!(:non_permanent_variant) { create(:cm_base_variant, is_master: false, product: non_permanent_product, total_inventory: 10) }

  let(:pre_inventory_days) { 3 }

  before do
    allow_any_instance_of(Spree::Variant).to receive(:pre_inventory_days).and_return(pre_inventory_days)
  end

  describe '.call' do
    it 'generate 3 inventory_items = 3 days for permanent_stock variant only' do
      expect { described_class.call }.to change { permanent_variant.inventory_items.count }.by(pre_inventory_days)
      expect(non_permanent_variant.inventory_items.count).to eq(0)

      expect(permanent_variant.inventory_items.pluck(:quantity_available)).to eq [5, 5, 5]
      expect(permanent_variant.inventory_items.pluck(:max_capacity)).to eq [5, 5, 5]
      expect(permanent_variant.inventory_items.pluck(:product_type)).to eq ['accommodation', 'accommodation', 'accommodation']
    end

    it 'does not create duplicate inventory items if they already exist' do
      existing_date = Date.tomorrow

      permanent_variant.inventory_items.create!(
        inventory_date: existing_date,
        quantity_available: 3,
        max_capacity: 3,
        product_type: permanent_variant.product_type
      )

      expect {
        described_class.call
      }.to change { permanent_variant.inventory_items.count }.by(pre_inventory_days - 1)

      expect(permanent_variant.inventory_items.pluck(:quantity_available)).to eq [3, 5, 5]
      expect(permanent_variant.inventory_items.pluck(:max_capacity)).to eq [3, 5, 5]
      expect(permanent_variant.inventory_items.pluck(:product_type)).to eq ['accommodation', 'accommodation', 'accommodation']
    end

    it 'generate for variant in :variant_ids if provided' do
      permanent_variant2 = create(:cm_base_variant, is_master: false, product: permanent_product, total_inventory: 5)

      expect {
        described_class.call(variant_ids: [permanent_variant2.id])
      }.to change { permanent_variant2.inventory_items.count }.by(pre_inventory_days)

      expect(non_permanent_variant.inventory_items.count).to eq(0)
      expect(permanent_variant.inventory_items.count).to eq(0)
    end

    it 'run generation in 2 batch when variants is more than :variants_per_batch' do
      permanent_variant2 = create(:cm_base_variant, is_master: false, product: permanent_product, total_inventory: 5)
      permanent_variant3 = create(:cm_base_variant, is_master: false, product: permanent_product, total_inventory: 5)

      allow_any_instance_of(described_class).to receive(:variants_per_batch).and_return(2)
      expect_any_instance_of(described_class).to receive(:generate_inventory_items_for_batch).twice.and_call_original

      described_class.call

      expect(permanent_variant.inventory_items.count).to eq(pre_inventory_days)
      expect(permanent_variant2.inventory_items.count).to eq(pre_inventory_days)
      expect(permanent_variant3.inventory_items.count).to eq(pre_inventory_days)
    end
  end
end
