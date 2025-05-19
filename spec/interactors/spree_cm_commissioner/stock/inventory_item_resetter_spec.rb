require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Stock::InventoryItemResetter, type: :interactor do
  describe '.call' do
    context 'mock test' do
      let(:product) { create(:cm_product, product_type: :ecommerce) }
      let(:variant) { create(:cm_variant, product: product, pregenerate_inventory_items: true, total_inventory: 5) }
      let(:inventory_item) { variant.inventory_items.first }

      it 'update inventory_item base on value of :variant_total_inventory & :variant_total_purchases' do
        inventory_item.update(max_capacity: 2, quantity_available: 20) # update to incorrect value to make it out of sync.

        expect_any_instance_of(described_class).to receive(:variant_total_inventory).and_return(20)
        expect_any_instance_of(described_class).to receive(:variant_total_purchases).and_return(13)

        described_class.call(inventory_item: inventory_item)

        expect(inventory_item.max_capacity).to eq 20
        expect(inventory_item.quantity_available).to eq(20 - 13)
      end
    end

    context 'no mock test' do
      let(:product) { create(:cm_product, product_type: :ecommerce) }
      let(:variant) { create(:cm_variant, product: product, pregenerate_inventory_items: true, total_inventory: 5) }
      let(:inventory_item) { variant.inventory_items.first }

      let(:line_item1) { create(:line_item, variant: variant, quantity: 2, price: 0) }
      let(:line_item2) { create(:line_item, variant: variant, quantity: 1, price: 0) }

      let!(:order1) { create(:order, line_items: [line_item1], state: :complete, completed_at: Time.now) }
      let!(:order2) { create(:order, line_items: [line_item2], state: :complete, completed_at: Time.now) }

      # make some purchase for variant.
      # perform enqueued jobs to make sure it unstock from redis & sync to inventory item
      before do
        perform_enqueued_jobs do
          order1.send(:unstock_inventory_in_redis!)
          order2.send(:unstock_inventory_in_redis!)
        end

        SpreeCmCommissioner.redis_pool.with do |redis|
          expect(variant.total_on_hand).to eq 5
          expect(variant.inventory_items.size).to eq 1
          expect(inventory_item.reload.quantity_available).to eq(5 - 2 - 1)
          expect(redis.get(inventory_item.redis_key).to_i).to eq(5 - 2 - 1)
        end
      end

      it 'reset inventory :max_capacity & :quantity_available to correct value base on orders' do
        inventory_item.update(max_capacity: 2, quantity_available: 20) # update to incorrect value to make it out of sync.
        described_class.call(inventory_item: inventory_item)

        expect(inventory_item.max_capacity).to eq variant.total_on_hand
        expect(inventory_item.quantity_available).to eq(5 - 2 - 1)

        # it remove key from redis after resetted
        SpreeCmCommissioner.redis_pool.with do |redis|
          expect(redis.get(inventory_item.redis_key)).to eq nil
        end
      end
    end
  end

  describe '#variant_total_inventory' do
    context 'for ecommerce with shipment' do
      let(:product) { create(:cm_product, product_type: :ecommerce) }
      let(:variant) { create(:cm_variant, product: product, delivery_required: true, pregenerate_inventory_items: true, total_inventory: 5) }
      let(:inventory_item) { variant.inventory_items.first }

      let(:line_item1) { create(:line_item, variant: variant, quantity: 2, price: 0) }
      let(:line_item2) { create(:line_item, variant: variant, quantity: 1, price: 0) }

      let(:order_with_shipment_1) { create(:shipped_order, line_items: [line_item1], state: :confirm) }
      let(:order_with_shipment_2) { create(:shipped_order, line_items: [line_item2], state: :confirm) }

      subject { described_class.new(inventory_item: inventory_item.reload) }

      # make some purchase for variant which make shipment subtract the stock.
      before do
        expect(variant.stock_items.first.count_on_hand).to eq 5

        order_with_shipment_1.next
        order_with_shipment_2.next

        expect(variant.stock_items.first.count_on_hand).to eq(5 - 2 - 1)
      end

      it 'return total inventory total_on_hand + purchase total' do
        expect(variant.total_on_hand).to eq(2)
        expect(variant.complete_line_items.sum(:quantity)).to eq(3)

        expect(subject.variant_total_inventory).to eq 5
      end
    end

    context 'for ecommerce with no shipment (event, digital product)' do
      let(:product) { create(:cm_product, product_type: :ecommerce) }
      let(:variant) { create(:cm_variant, product: product, pregenerate_inventory_items: true, total_inventory: 5) }
      let(:inventory_item) { variant.inventory_items.first }

      let(:line_item1) { create(:line_item, variant: variant, quantity: 2, price: 0) }
      let!(:order1) { create(:order, line_items: [line_item1], state: :complete, completed_at: Time.now) }

      subject { described_class.new(inventory_item: inventory_item) }

      it 'just return total_on_hand of stock item directly' do
        expect(subject.variant_total_inventory).to eq variant.total_on_hand
      end
    end
  end

  describe '#variant_total_purchases' do
    context 'for permanent stock' do
      let(:accommodation_variant) { create(:cm_variant, product_type: :accommodation, pregenerate_inventory_items: true, total_inventory: 5, pre_inventory_days: 1) }
      let(:service_variant) { create(:cm_variant, product_type: :service, pregenerate_inventory_items: true, total_inventory: 5, pre_inventory_days: 1) }
      let(:ecommerce_variant) { create(:cm_variant, product_type: :ecommerce, pregenerate_inventory_items: true, total_inventory: 5) }

      let(:accommodation_inventory_item) { accommodation_variant.inventory_items[0] }
      let(:service_inventory_item) { service_variant.inventory_items[0] }
      let(:ecommerce_inventory_item) { ecommerce_variant.inventory_items[0] }

      let(:accommodation_line_item1) { create(:line_item, quantity: 2, variant: accommodation_variant, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow) }
      let(:service_line_item1) { create(:line_item, quantity: 2, variant: service_variant, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow) }
      let(:ecommerce_line_item1) { create(:line_item, quantity: 2, variant: ecommerce_variant) }

      let(:accommodation_line_item2) { create(:line_item, quantity: 1, variant: accommodation_variant, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow) }
      let(:service_line_item2) { create(:line_item, quantity: 1, variant: service_variant, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow) }
      let(:ecommerce_line_item2) { create(:line_item, quantity: 1, variant: ecommerce_variant) }

      # create transit line item is impossible now some old validation. We need to work on that first.
      # let(:transit_line_item) { create(:line_item, variant: service_variant, from_date: Time.zone.tomorrow, to_date: Time.zone.tomorrow + 1) }

      before do
        create(:order, line_items: [accommodation_line_item1, service_line_item1, ecommerce_line_item1], state: :complete, completed_at: Time.now)
        create(:order, line_items: [accommodation_line_item2, service_line_item2, ecommerce_line_item2], state: :complete, completed_at: Time.now)
      end

      it 'return total purchase on line item total' do
        subject1 = described_class.new(inventory_item: accommodation_inventory_item)
        subject2 = described_class.new(inventory_item: service_inventory_item)
        subject3 = described_class.new(inventory_item: ecommerce_inventory_item)

        expect(subject1.variant_total_purchases).to eq(3)
        expect(subject2.variant_total_purchases).to eq(3)
        expect(subject3.variant_total_purchases).to eq(3)
      end
    end
  end
end
