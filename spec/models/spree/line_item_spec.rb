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

  context 'validations' do
    describe "#validate_if_allowed_to_decrease_quantity" do
      let(:line_item) { create(:line_item, quantity: 2) }

      context 'when line item is not kyc' do
        before do
          allow(line_item).to receive(:kyc?).and_return(false)
        end

        it 'should not run validation if it is not kyc' do
          line_item.quantity = line_item.quantity + 1
          line_item.save

          expect(line_item).to_not receive(:validate_if_allowed_to_decrease_quantity)
        end
      end

      context 'when line item is kyc' do
        before do
          allow(line_item).to receive(:kyc?).and_return(true)
        end

        it 'should not raise any error if line item quantity is increasing' do
          line_item.quantity = line_item.quantity + 1

          expect(line_item.save).to be true
        end

        it 'should not raise any error if line item can be decreased' do
          allow(line_item).to receive(:allowed_to_decrease_quantity?).and_return(true)

          # decreasing
          line_item.quantity = line_item.quantity - 1

          expect(line_item.save).to be true
        end

        it 'should raise error if line item quantity is decreasing & not allowed to decrease' do
          allow(line_item).to receive(:allowed_to_decrease_quantity?).and_return(false)

          # decreasing
          line_item.quantity = line_item.quantity - 1

          expect(line_item.save).to be false
          expect(line_item.errors.full_messages).to eq ['Quantity must_remove_some_guests']
        end
      end
    end
  end

  describe "#allowed_to_decrease_quantity?" do
    let(:line_item1) { create(:line_item) }
    let(:line_item2) { create(:line_item) }

    context 'when line item is not kyc' do
      it 'should return true if line item is not kyc' do
        allow(line_item1).to receive(:kyc?).and_return(false)

        expect(line_item1.allowed_to_decrease_quantity?).to be true
      end
    end

    context 'when line item is kyc' do
      before do
        allow(line_item1).to receive(:kyc?).and_return(true)
        allow(line_item2).to receive(:kyc?).and_return(true)
      end

      it 'should return true if remaining_total_guest >= 0' do
        allow(line_item1).to receive(:remaining_total_guests).and_return(0)
        allow(line_item2).to receive(:remaining_total_guests).and_return(1)

        expect(line_item1.allowed_to_decrease_quantity?).to be true
        expect(line_item2.allowed_to_decrease_quantity?).to be true
      end

      it 'should return false if remaining_total_guest < 0' do
        allow(line_item1).to receive(:remaining_total_guests).and_return(-1)

        expect(line_item1.allowed_to_decrease_quantity?).to be false
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

  describe 'paid' do
    let!(:order1) { create(:order_with_line_items, payment_state: :paid, line_items_count: 1) }
    let!(:order2) { create(:order_with_line_items, payment_state: :void, line_items_count: 1) }

    it 'it only return paid line items' do
      expect(described_class.paid.size).to eq 1
      expect(described_class.paid).to eq order1.line_items
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

  describe '#accepted_by' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    it "save accepter & date to database if both yet present" do
      line_item = create(:line_item, accepted_at: nil, accepter: nil)
      line_item.accepted_by(user1)

      expect(line_item.accepted_at).to_not be_nil
      expect(line_item.accepter_id).to eq user1.id
    end

    it "save new accepter & date to database if only accepted_at present" do
      line_item = create(:line_item, accepted_at: '2024-03-11'.to_date, accepter: nil)
      line_item.accepted_by(user1)

      expect(line_item.accepted_at).to_not be_nil
      expect(line_item.accepter_id).to eq user1.id
    end

    it "save new accepter & date to database if only accepter present" do
      line_item = create(:line_item, accepted_at: nil, accepter: user1)
      line_item.accepted_by(user2)

      expect(line_item.accepted_at).to_not be_nil
      expect(line_item.accepter_id).to eq(user2.id)
    end
  end

  describe '#rejected_by' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    it "save rejecter & date to database if both yet present" do
      line_item = create(:line_item, rejected_at: nil, rejecter: nil)
      line_item.rejected_by(user1)

      expect(line_item.rejected_at).to_not be_nil
      expect(line_item.rejecter_id).to eq user1.id
    end

    it "save new rejecter & date to database if only rejected_at present" do
      line_item = create(:line_item, rejected_at: '2024-03-11'.to_date, rejecter: nil)
      line_item.rejected_by(user1)

      expect(line_item.rejected_at).to_not be_nil
      expect(line_item.rejecter_id).to eq user1.id
    end

    it "save new rejecter & date to database if only rejecter present" do
      line_item = create(:line_item, rejected_at: nil, rejecter: user1)
      line_item.rejected_by(user2)

      expect(line_item.rejected_at).to_not be_nil
      expect(line_item.rejecter_id).to eq(user2.id)
    end
  end

  describe '#date_range_excluding_checkout' do
    let(:line_item) { create(:line_item, from_date: '2023-01-10'.to_date, to_date: '2023-01-13'.to_date) }

    it 'return date range without checkout date' do
      expect(line_item.date_range_excluding_checkout).to eq (['2023-01-10'.to_date, '2023-01-11'.to_date, '2023-01-12'.to_date])
    end
  end

  describe '#date_range_including_checkout' do
    let(:line_item) { create(:line_item, from_date: '2023-01-10'.to_date, to_date: '2023-01-13'.to_date) }

    it 'return date range without checkout date' do
      expect(line_item.date_range_including_checkout).to eq (['2023-01-10'.to_date, '2023-01-11'.to_date, '2023-01-12'.to_date, '2023-01-13'.to_date])
    end
  end

  describe '#date_range' do
    let(:line_item) { create(:line_item, from_date: '2023-01-10'.to_date, to_date: '2023-01-13'.to_date) }

    it 'return date_range_excluding_checkout when it is accomodation' do
      allow(line_item).to receive(:accommodation?).and_return(true)

      expect(line_item.date_range).to eq (line_item.date_range_excluding_checkout)
    end

    it 'return date_range_including_checkout when it is not accomodation' do
      allow(line_item).to receive(:accommodation?).and_return(false)

      expect(line_item.date_range).to eq (line_item.date_range_including_checkout)
    end
  end

  describe '#date_unit' do
    let(:line_item) { create(:line_item, from_date: '2023-01-10'.to_date, to_date: '2023-01-13'.to_date) }

    it 'return number of night when it is accomodation' do
      allow(line_item).to receive(:accommodation?).and_return(true)

      expect(line_item.date_unit).to eq 3
    end
  end
end
