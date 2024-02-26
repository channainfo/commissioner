require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ConversionPreCalculatorJob, type: :job do
  describe '#perform' do
    let(:taxon) { create(:taxon, name: "Event Sub Section") }
    let(:product_taxon1) { create(:cm_product_taxon, taxon: taxon) }
    let(:product_taxon2) { create(:cm_product_taxon, taxon: taxon) }
    let(:line_items) do
      [
        create(:cm_line_item, quantity: 5, product: product_taxon1.product),
        create(:cm_line_item, quantity: 10, product: product_taxon1.product),
        create(:cm_line_item, quantity: 5, product: product_taxon2.product)
      ]
    end
    let(:order) { create(:order, line_items: line_items, completed_at: '2024-03-11'.to_date) }

    it 'should call the interactor with correct parameters' do
      expect(SpreeCmCommissioner::ConversionPreCalculator)
        .to receive(:call).with(product_taxon: instance_of(Spree::Classification)).twice
      described_class.perform_now(product_taxon1.product_id)
      described_class.perform_now(product_taxon2.product_id)
    end

    it 'should return default total_count of 0 for all product_taxons' do
      expect(product_taxon1.reload.total_count).to eq(0)
      expect(product_taxon2.reload.total_count).to eq(0)
    end

    it 'should update the total_count of each product_taxon' do
      order
      described_class.perform_now(product_taxon1.product_id)
      described_class.perform_now(product_taxon2.product_id)

      expect(product_taxon1.reload.total_count).to eq(15)
      expect(product_taxon2.reload.total_count).to eq(5)
    end

    it 'should return default revenue of 0 for all product_taxons' do
      expect(product_taxon1.reload.revenue).to eq(0)
      expect(product_taxon2.reload.revenue).to eq(0)
    end

    it 'should update the revenue of each product_taxon' do
      order
      described_class.perform_now(product_taxon1.product_id)
      described_class.perform_now(product_taxon2.product_id)

      expect(product_taxon1.reload.revenue).to eq(150)
      expect(product_taxon2.reload.revenue).to eq(50)
    end

    it 'should not update the total_count and revenue of product_taxon if line_items are not completed' do
      order.update(completed_at: nil)
      described_class.perform_now(product_taxon1.product_id)
      described_class.perform_now(product_taxon2.product_id)

      expect(product_taxon1.reload.total_count).to eq(0)
      expect(product_taxon2.reload.total_count).to eq(0)
      expect(product_taxon1.reload.revenue).to eq(0)
      expect(product_taxon2.reload.revenue).to eq(0)
    end
  end
end
