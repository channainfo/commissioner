require 'spec_helper'

RSpec.describe Spree::LineItem, type: :model do
  describe '#callback before_save' do
    let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
    let!(:vendor) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel', default_state_id: phnom_penh.id) }
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

  describe '#set_duration' do

    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:taxon) { taxon = create(:taxon, name: 'events', from_date: '2023-01-10'.to_date, to_date: '2023-01-13'.to_date, taxonomy: taxonomy) }
    let(:product) { create(:product, taxons: [taxon]) }
    let(:order) { create(:order) }

    it 'save duration to line item base on event' do

      line_item = order.line_items.create(variant: product.master)

      expect(line_item.from_date).to eq taxon.from_date
      expect(line_item.to_date).to eq taxon.to_date
    end

    it 'not save duration to line item already has duration' do
      line_item = order.line_items.create(variant: product.master, from_date: '2024-03-11'.to_date, to_date: '2024-03-15'.to_date)

      expect(line_item.from_date).to eq '2024-03-11'.to_date
      expect(line_item.to_date).to eq '2024-03-15'.to_date
    end
  end

  describe '#amount' do
    context 'product type: accommodation' do
      let(:product) { create(:cm_accommodation_product, price: BigDecimal('10.0'), permanent_stock: 4) }
      let(:line_item) { create(:line_item, price: BigDecimal('10.0'), quantity: 2, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-13'.to_date) }

      it 'caculate amount base on price, quantity & number of nights' do
        expect(line_item.amount).to eq BigDecimal('60.0') # 10.0 * 2 * 3 nights
      end
    end

    context 'product type: ecommerce' do
      let(:product) { create(:cm_product, price: BigDecimal('10.0'), product_type: :ecommerce) }
      let(:line_item) { create(:line_item, price: BigDecimal('10.0'), quantity: 2, product: product) }

      it 'caculate amount base on price & quantity' do
        expect(line_item.amount).to eq BigDecimal('20.0') # 10.0 * 2
      end
    end
  end

  describe '.complete' do
    let!(:complete_order) { create(:order, completed_at: '2024-03-11'.to_date) }
    let!(:incomplete_order) { create(:order, completed_at: nil) }

    it 'filter only complete line items base on complete order' do
      line_item1 = create(:line_item, order: complete_order)
      line_item2 = create(:line_item, order: incomplete_order)

      expect(described_class.complete).to eq [line_item1]
    end
  end

  describe '#reservation?' do
    let(:ecommerce) { build(:product, product_type: :ecommerce)}
    let(:service) { build(:product, product_type: :service)}
    let(:accommodation) { build(:product, product_type: :accommodation)}

    it 'not considered reservation if it not either service or accommodation' do
      line_item = build(:line_item, variant: ecommerce.master)
      expect(line_item.reservation?).to be false
    end

    it 'not considered reservation if it not contains duration' do
      line_item1 = build(:line_item, variant: accommodation.master)
      line_item2 = build(:line_item, variant: accommodation.master)

      expect(line_item1.reservation?).to be false
      expect(line_item2.reservation?).to be false
    end

    it 'not considered reservation if it ecommerce [even it has duration]' do
      line_item = build(:line_item, variant: ecommerce.master, from_date: '2024-03-11'.to_date, to_date: '2024-03-13'.to_date)

      expect(line_item.reservation?).to be false
    end

    it 'considered reservation if it service / accomodation, has date & not subscription' do
      line_item1 = build(:line_item, variant: accommodation.master, from_date: '2024-03-11'.to_date, to_date: '2024-03-13'.to_date)
      line_item2 = build(:line_item, variant: service.master, from_date: '2024-03-11'.to_date, to_date: '2024-03-13'.to_date)

      expect(line_item1.reservation?).to be true
      expect(line_item2.reservation?).to be true
    end
  end
end
