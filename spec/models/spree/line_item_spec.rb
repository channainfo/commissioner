require 'spec_helper'

RSpec.describe Spree::LineItem, type: :model do
  describe '.whitelisted_ransackable_associations' do
    it 'returns expected associations' do
      expect(described_class.whitelisted_ransackable_associations).to match_array([
        "variant", "order", "tax_category", "guests"
      ])
    end
  end

  describe '.whitelisted_ransackable_attributes' do
    it 'returns expected attributes' do
      expect(described_class.whitelisted_ransackable_attributes).to match_array([
        "variant_id", "order_id", "tax_category_id", "quantity", "price", "cost_price", "cost_currency", "adjustment_total",
        "additional_tax_total", "promo_total", "included_tax_total", "pre_tax_amount", "taxable_adjustment_total",
        "non_taxable_adjustment_total", "number", "to_date", "from_date", "vendor_id"
      ])
    end
  end

  describe '.inventory_items' do
    context 'when product_type is ecommerce' do
      let(:product) { create(:cm_product, product_type: :ecommerce) }
      let(:variant) { create(:cm_variant, product: product, total_inventory: 10) }
      let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow + 3) }

      it 'only return an inventory item' do
        expect(line_item.inventory_items.size).to eq 1
        expect(line_item.inventory_items[0].inventory_date).to eq nil
      end
    end

    context 'when product_type is accommodation' do
      let(:product) { create(:cm_product, product_type: :accommodation) }
      let(:variant) { create(:cm_variant, product: product, total_inventory: 10) }
      let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow + 2) }

      # generate inventory items for 10 days
      before do
        allow_any_instance_of(Spree::Variant).to receive(:pre_inventory_days).and_return(10)
        SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator.call(variant_ids: [variant.id])
      end

      it 'only return inventory items from from_date to to_date but exclude checkout date' do
        expect(line_item.inventory_items.size).to eq 3
        expect(line_item.inventory_items[0].inventory_date).to eq Time.zone.tomorrow
        expect(line_item.inventory_items[1].inventory_date).to eq Time.zone.tomorrow + 1
        expect(line_item.inventory_items[2].inventory_date).to eq Time.zone.tomorrow + 2
      end
    end

    context 'when product_type is service' do
      let(:product) { create(:cm_product, product_type: :service) }
      let(:variant) { create(:cm_variant, product: product, total_inventory: 10) }
      let(:line_item) { create(:line_item, variant: variant, quantity: 1, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow + 3) }

      # generate inventory items for 10 days
      before do
        allow_any_instance_of(Spree::Variant).to receive(:pre_inventory_days).and_return(10)
        SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator.call(variant_ids: [variant.id])
      end

      it 'return all inventory items from from_date to to_date' do
        expect(line_item.inventory_items.size).to eq 4

        expect(line_item.inventory_items[0].inventory_date).to eq Time.zone.tomorrow
        expect(line_item.inventory_items[1].inventory_date).to eq Time.zone.tomorrow + 1
        expect(line_item.inventory_items[2].inventory_date).to eq Time.zone.tomorrow + 2
        expect(line_item.inventory_items[3].inventory_date).to eq Time.zone.tomorrow + 3
      end
    end
  end

  describe '#callback before_save' do
    let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
    let!(:vendor) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', default_state_id: phnom_penh.id) }
    let!(:variant) { vendor.variants.first }
    let!(:order) { create(:order) }
    let(:line_item) { order.line_items.build(variant_id: variant.id) }

    context '#update_vendor_id' do
      it 'adds vendor_id to line_item' do
        line_item.save
        expect(line_item.vendor_id).to eq vendor.id
      end
    end
  end

  describe 'callback before_validation' do
    let(:line_item) { build(:line_item) }

    describe 'Spree::Core::NumberGenerator#generate_permalink' do
      it 'generates number for line item with base length 10' do
        expect(line_item.number).to eq nil

        line_item.save

        expect(line_item.number.size).to eq 10
      end
    end

    describe '#set_duration' do
      let(:option_type1) { create(:cm_option_type, :start_date) }
      let(:option_type2) { create(:cm_option_type, :start_time) }
      let(:option_type3) { create(:cm_option_type, :end_date) }
      let(:option_type4) { create(:cm_option_type, :end_time) }

      let(:option_value1) { create(:cm_option_value, name: '2024-01-01', option_type: option_type1) }
      let(:option_value2) { create(:cm_option_value, name: '03:00:00', option_type: option_type2) }
      let(:option_value3) { create(:cm_option_value, name: '2024-02-02', option_type: option_type3) }
      let(:option_value4) { create(:cm_option_value, name: '05:00:00', option_type: option_type4) }

      let(:product) { create(:cm_product, option_types: [option_type1, option_type2, option_type3, option_type4]) }
      let(:variant) { create(:cm_variant, product: product, option_values: [option_value1, option_value2, option_value3, option_value4]) }

      context 'when from_date & to_date are not present' do
        let(:line_item) { build(:line_item, variant: variant, from_date: nil, to_date: nil) }

        it 'sets from_date & to_date based on variant' do
          line_item.save

          expect(line_item.from_date).to eq Time.zone.parse('2024-01-01 03:00:00')
          expect(line_item.to_date).to eq Time.zone.parse('2024-02-02 05:00:00')
        end
      end

      context 'when from_date & to_date are already present' do
        let(:line_item) { build(:line_item, variant: variant, from_date: '2024-08-08 02:00:00', to_date: '2024-08-09 04:00:00') }

        it 'does not change from_date & to_date' do
          line_item.save

          expect(line_item.from_date).to eq Time.zone.parse('2024-08-08 02:00:00')
          expect(line_item.to_date).to eq Time.zone.parse('2024-08-09 04:00:00')
        end
      end
    end
  end

  describe 'validations' do
    context 'ensures quantity does not exceed max-quantity-per-order' do
      let(:line_item) { create(:line_item) }

      before do
        allow(line_item.variant).to receive(:max_quantity_per_order).and_return(3)
      end

      context 'when quantity is within max_quantity_per_order' do
        it 'is valid' do
          line_item.quantity = 3
          expect(line_item).to be_valid
        end
      end

      context 'when quantity exceeds max_quantity_per_order' do
        it 'is invalid' do
          line_item.quantity = 6
          expect(line_item).not_to be_valid
          expect(line_item.errors[:quantity]).to include('exceeded_max_quantity_per_order')
        end
      end

      context 'when max_quantity_per_order is not set' do
        it 'is always valid' do
          allow(line_item.variant).to receive(:max_quantity_per_order).and_return(nil)

          line_item.quantity = 100
          expect(line_item).to be_valid
        end
      end
    end
  end

  describe '#completion_steps' do
    let(:line_item) { create(:line_item) }
    let(:product) { line_item.product }

    context 'when product_completion_steps exist' do
      let!(:product_completion_step1) { create(:cm_chatrace_tg_product_completion_step, product: product) }
      let!(:product_completion_step2) { create(:cm_chatrace_tg_product_completion_step, product: product) }

      it 'returns an array of hashes with completion steps' do
        expected_hash1 = product_completion_step1.construct_hash(line_item: line_item)
        expected_hash2 = product_completion_step2.construct_hash(line_item: line_item)

        expect(line_item.completion_steps).to contain_exactly(expected_hash1, expected_hash2)
      end
    end

    context 'when no product_completion_steps exist' do
      it 'returns an empty array' do
        expect(line_item.completion_steps).to eq([])
      end
    end
  end

  describe '#amount' do
    context 'product type: accommodation' do
      let(:product) { create(:cm_accommodation_product, price: BigDecimal('10.0'), total_inventory: 4) }
      let(:line_item) { create(:line_item, price: BigDecimal('10.0'), quantity: 2, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }

      it 'calculates amount based on price, quantity & number of nights' do
        expect(line_item.amount).to eq BigDecimal('60.0') # 10.0 * 2 * 3 nights
      end
    end

    context 'product type: ecommerce' do
      let(:product) { create(:cm_product, price: BigDecimal('10.0'), product_type: :ecommerce) }
      let(:line_item) { create(:line_item, price: BigDecimal('10.0'), quantity: 2, product: product) }

      it 'calculates amount based on price & quantity' do
        expect(line_item.amount).to eq BigDecimal('20.0') # 10.0 * 2
      end
    end
  end

  describe '.complete' do
    let!(:complete_order) { create(:order, completed_at: '2024-03-11'.to_date) }
    let!(:incomplete_order) { create(:order, completed_at: nil) }

    it 'filters only complete line items based on complete order' do
      line_item1 = create(:line_item, order: complete_order)
      _line_item2 = create(:line_item, order: incomplete_order)

      expect(described_class.complete).to eq [line_item1]
    end
  end

  describe '.paid' do
    let!(:order1) { create(:order_with_line_items, payment_state: :paid, line_items_count: 1) }
    let!(:order2) { create(:order_with_line_items, payment_state: :void, line_items_count: 1) }

    it 'returns only paid line items' do
      paid_line_item = order1.line_items.first
      void_line_item = order2.line_items.first

      expect(described_class.paid).to contain_exactly(paid_line_item)
      expect(described_class.paid).not_to include(void_line_item)
    end
  end
end
