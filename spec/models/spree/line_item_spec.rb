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

  describe 'callback before_validation' do
    let(:line_item) { build(:line_item) }

    describe 'Spree::Core::NumberGenerator#generate_permalink' do
      it 'generate number for line item with base length 10' do
        expect(line_item.number).to eq nil

        line_item.save

        expect(line_item.number.size).to eq 10
      end
    end
  end

  describe 'validations' do
    context 'make sure quantity not exceed max-quantity-per-order' do
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
      let(:product) { create(:cm_accommodation_product, price: BigDecimal('10.0'), total_inventory: 4) }
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
      allow(line_item).to receive(:permanent_stock?).and_return(true)

      expect(line_item.date_range).to eq (line_item.date_range_excluding_checkout)
    end

    it 'return date_range_including_checkout when it is not accomodation' do
      allow(line_item).to receive(:accommodation?).and_return(false)
      allow(line_item).to receive(:permanent_stock?).and_return(true)

      expect(line_item.date_range).to eq (line_item.date_range_including_checkout)
    end
  end

  describe '#date_unit' do
    let(:line_item) { create(:line_item, from_date: '2023-01-10'.to_date, to_date: '2023-01-13'.to_date) }

    it 'return number of night when it is accomodation' do
      allow(line_item).to receive(:accommodation?).and_return(true)
      allow(line_item).to receive(:permanent_stock?).and_return(true)

      expect(line_item.date_unit).to eq 3
    end
  end

  describe '#number_of_guests' do
    let(:line_item) { create(:line_item, quantity: 2) }

    it 'return number of guest base on variant and quantity' do
      allow(line_item.variant).to receive(:number_of_kids).and_return(1)
      allow(line_item.variant).to receive(:number_of_adults).and_return(2)

      expect(line_item.variant.number_of_guests).to eq 3
      expect(line_item.number_of_guests).to eq 6
    end
  end

  describe '#remaining_total_guests' do
    let(:line_item) { create(:line_item) }

    it 'return number of guest base on variant and quantity' do
      allow(line_item).to receive(:number_of_guests).and_return(3)
      allow(line_item.guests).to receive(:size).and_return(2)

      expect(line_item.remaining_total_guests).to eq 1
    end
  end

  context 'guest options' do
    describe '#number_of_adults' do
      let(:variant) { create(:variant, option_values: [adults(4), allowed_extra_adults(2)]) }

      context 'when public metadata is provided' do
        it 'return number_of_adults base on public_metadata' do
          line_item = create(:line_item, quantity: 2, variant: variant, public_metadata: { number_of_adults: 6 })

          expect(line_item.number_of_adults).to eq 6
        end
      end

      context 'when public_metadata is not provided' do
        it 'return number_of_adults base on variant adults' do
          line_item = create(:line_item, quantity: 1, variant: variant)

          expect(line_item.variant.number_of_adults).to eq 4
          expect(line_item.number_of_adults).to eq 4
        end

        it 'return number_of_adults base on variant adults x quantity' do
          quantity = 2
          line_item = create(:line_item, quantity: quantity, variant: variant)

          expect(line_item.variant.number_of_adults).to eq 4
          expect(line_item.number_of_adults).to eq 4 * quantity
        end
      end
    end

    describe '#number_of_kids' do
      let(:variant) { create(:variant, option_values: [kids(4), allowed_extra_kids(3)]) }

      context 'when public metadata is provided' do
        it 'return actual number of kids base on public_metadata' do
          line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_kids: 6 })

          expect(line_item.number_of_kids).to eq 6
        end
      end

      context 'when public_metadata is not provided' do
        it 'return actual number of kids base on variant kids' do
          line_item = create(:line_item, quantity: 1, variant: variant)

          expect(line_item.variant.number_of_kids).to eq 4
          expect(line_item.number_of_kids).to eq 4
        end

        it 'return actual number of kids base on variant kids x quantity' do
          quantity = 2
          line_item = create(:line_item, quantity: quantity, variant: variant)

          expect(line_item.variant.number_of_kids).to eq 4
          expect(line_item.number_of_kids).to eq 4 * quantity
        end
      end
    end

    describe '#extra_adults' do
      let(:variant) { create(:variant, option_values: [adults(4), allowed_extra_adults(2)]) }

      it 'should return 2 extra adults' do
        line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_adults: 5 })

        expect(line_item.extra_adults).to eq 1
      end

      it 'should return 0 when extra_adults? false' do
        line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_adults: 5 })
        allow(line_item).to receive(:extra_adults?).and_return(false)

        expect(line_item.extra_adults).to eq 0
      end
    end

    describe '#extra_kids' do
      let(:variant) { create(:variant, option_values: [kids(4), allowed_extra_kids(3)]) }

      it 'should return 2 extra kids' do
        line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_kids: 6 })

        expect(line_item.extra_kids).to eq 2
      end

      it 'should return 0 when extra_kids? false' do
        line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_kids: 6 })
        allow(line_item).to receive(:extra_kids?).and_return(false)

        expect(line_item.extra_kids).to eq 0
      end
    end

    describe '#extra_adults?' do
      let(:variant) { create(:variant, option_values: [adults(4), allowed_extra_adults(2)]) }

      it 'return false when public_metadata[:number_of_adults] not present?' do
        line_item = create(:line_item, quantity: 1, variant: variant)

        expect(line_item.extra_adults?).to eq false
      end

      it 'return false when number_of_adults 4 is not exceeding variant number of adults 4' do
        line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_adults: 4 })

        expect(line_item.variant.number_of_adults).to eq 4
        expect(line_item.number_of_adults).to eq 4
        expect(line_item.extra_adults?).to eq false
      end

      it 'return true when number_of_adults 5 is exceeding variant number of adults 4' do
        line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_adults: 5 })

        expect(line_item.variant.number_of_adults).to eq 4
        expect(line_item.number_of_adults).to eq 5
        expect(line_item.extra_adults?).to eq true
      end
    end

    describe '#extra_kids?' do
      let(:variant) { create(:variant, option_values: [kids(4), allowed_extra_kids(3)]) }

      it 'return false when public_metadata[:number_of_kids] not present?' do
        line_item = create(:line_item, quantity: 1, variant: variant)

        expect(line_item.extra_kids?).to eq false
      end

      it 'return false when number_of_kids 4 is not exceeding variant number of kids 4' do
        line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_kids: 4 })

        expect(variant.number_of_kids).to eq 4
        expect(line_item.number_of_kids).to eq 4
        expect(line_item.extra_kids?).to eq false
      end

      it 'return true when number_of_kids 5 is exceeding variant number of kids 4' do
        line_item = create(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_kids: 5 })

        expect(variant.number_of_kids).to eq 4
        expect(line_item.number_of_kids).to eq 5
        expect(line_item.extra_kids?).to eq true
      end
    end

    context 'validate total adults' do
      let(:variant) { create(:variant, option_values: [adults(4), allowed_extra_adults(2)]) }

      it 'invalid when actual adults is exceed variant adults & allow extra adults' do
        line_item = build(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_adults: 7 })

        expect(line_item.allowed_total_adults).to eq 6
        expect { line_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
                                  .with_message("Validation failed: Quantity exceed_total_adults")
      end

      it 'invalid when actual adults is exceed variant adults & allow extra adults x quantity' do
        line_item = build(:line_item, quantity: 2, variant: variant, public_metadata: { number_of_adults: 13 })

        expect(line_item.allowed_total_adults).to eq 12
        expect { line_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
                                  .with_message("Validation failed: Quantity exceed_total_adults")
      end
    end

    context 'validate total kids' do
      let(:variant) { create(:variant, option_values: [kids(4), allowed_extra_kids(3)]) }

      it 'invalid when actual kids is exceed variant kids & allow extra kids' do
        line_item = build(:line_item, quantity: 1, variant: variant, public_metadata: { number_of_kids: 8 })

        expect(line_item.allowed_total_kids).to eq 7
        expect { line_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
                                  .with_message("Validation failed: Quantity exceed_total_kids")
      end

      it 'invalid when actual kids is exceed variant kids & allow extra kids x quantity' do
        line_item = build(:line_item, quantity: 2, variant: variant, public_metadata: { number_of_kids: 15 })

        expect(line_item.allowed_total_kids).to eq 14
        expect { line_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
                                  .with_message("Validation failed: Quantity exceed_total_kids")
      end
    end
  end

  def kids(number)
    kids_option_type = create(:cm_option_type, :number_of_kids)
    create(:option_value, presentation: "#{number}-kids", name: "#{number}", option_type: kids_option_type)
  end

  def adults(number)
    adults_option_type = create(:cm_option_type, :number_of_adults)
    create(:option_value, presentation: "#{number}-adults", name: "#{number}", option_type: adults_option_type)
  end

  def allowed_extra_kids(number)
    allowed_extra_kids_option_type = create(:cm_option_type, :allowed_extra_kids)
    create(:option_value, presentation: "allowed-#{number}-kids", name: "#{number}", option_type: allowed_extra_kids_option_type)
  end

  def allowed_extra_adults(number)
    allowed_extra_adults_option_type = create(:cm_option_type, :allowed_extra_adults)
    create(:option_value, presentation: "allowed-#{number}-adults", name: "#{number}", option_type: allowed_extra_adults_option_type)
  end
end
