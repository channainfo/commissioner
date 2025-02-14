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

      let(:product) { create(:product, option_types: [option_type1, option_type2, option_type3, option_type4]) }
      let(:variant) { create(:variant, product: product, option_values: [option_value1, option_value2, option_value3, option_value4]) }

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
      let(:line_item) { create(:line_item, price: BigDecimal('10.0'), quantity: 2, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-13'.to_date) }

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

  context 'transit?' do
    let!(:vet) {create(:vendor, name: 'Vet', code:"VET")}
    let!(:phnom_penh) { create(:transit_place, name: 'Phnom Penh', data_type:4) }
    let!(:siem_reap) { create(:transit_place, name: 'Siem Reap', data_type:4) }
    let!(:sihanoukville) { create(:transit_place, name: 'Sihanoukville', data_type:4) }
    let!(:koh_rong) { create(:transit_place, name: 'Koh Rong', data_type:4) }
    let!(:airbus) {create(:vehicle_type,
                      :with_seats,
                      code: "AIRBUS",
                      vendor: vet,
                      row: 10,
                      column: 5,
                      empty: [[0,2],[1,2],[2,2],[3,2],[4,2],[5,0],[5,1],[5,2],[6,0],[6,1],[6,2],[7,2],[8,2]]
                      )}
    let!(:ferry) {create(:vehicle_type,
                      code: 'ferry',
                      vendor: vet,
                      allow_seat_selection: false,
                      vehicle_seats_count: 20
                      )}
    let!(:arb_f1_seat) {airbus.vehicle_seats.find_by(label: "F1")}
    let!(:arb_f2_seat) {airbus.vehicle_seats.find_by(label: "F2")}
    let!(:arb_f3_seat) {airbus.vehicle_seats.find_by(label: "F3")}
    let!(:arb_f4_seat) {airbus.vehicle_seats.find_by(label: "F4")}
    let!(:bus1) {create(:vehicle, vehicle_type: airbus, vendor: vet)}
    let!(:ferry1) {create(:vehicle, vehicle_type: ferry, vendor: vet) }
    let!(:today) {Date.today}
    let!(:phnom_penh_to_siem_reap_by_airbus) { create(:route,
                                                      trip_attributes: {
                                                        origin_id: phnom_penh.id,
                                                        destination_id: siem_reap.id,
                                                        departure_time: '10:00',
                                                        duration: 18000,
                                                        vehicle_id: bus1.id
                                                      },
                                                      name: 'Phnom Penh to Siem Reap by Vet Airbus',
                                                      short_name:"PP-SR",
                                                      vendor: vet) }
    let!(:sihanoukville_to_koh_rong_by_ferry) {create(:route,
                                                      trip_attributes: {
                                                        origin_id: sihanoukville.id,
                                                        destination_id: koh_rong.id,
                                                        departure_time: '10:00',
                                                        duration: 21600,
                                                        vehicle_id: ferry1.id,
                                                        allow_seat_selection: false
                                                      },
                                                      name: "Buva Sea Sihanoukville to Koh Rong 10",
                                                      short_name: "SV-KR10-00-6",
                                                      vendor: vet)}
    describe '#validate_seats_reservation' do
      context "allow seat selection" do
        let!(:order1) { create(:order, state: :complete) }
        let!(:line_item1) {create(:line_item, quantity: 1, product:phnom_penh_to_siem_reap_by_airbus, order: order1, date: today)}
        let!(:line_item_seat_1) {create(:line_item_seat, line_item: line_item1, seat: arb_f1_seat, date: today, variant: phnom_penh_to_siem_reap_by_airbus.master)}
        let!(:order2) { create(:order, state: :cart) }
        let!(:order3) { create(:order, state: :payment) }
        let!(:order4) { create(:order, state: :complete, canceled_at: today) }
        let!(:line_item4) {create(:line_item, quantity: 1, product:phnom_penh_to_siem_reap_by_airbus, order: order4, date: today)}
        let!(:line_item_seat_4) {create(:line_item_seat, line_item: line_item4, seat: arb_f2_seat, date: today, variant: phnom_penh_to_siem_reap_by_airbus.master)}
        let(:selected_seats) {[]}
        before do
          @line_item_seats_attributes = selected_seats.map do |seat|
            {seat_id: seat.id, date:today,  variant_id: phnom_penh_to_siem_reap_by_airbus.master.id}
          end
        end
        context "error when at least one seat is already booked" do
          let(:selected_seats) {[arb_f1_seat,arb_f2_seat]}
          it "error when at least one seat is already booked when adding to cart" do
            result = Spree::Cart::AddItem.call(order: order2, variant: phnom_penh_to_siem_reap_by_airbus.master, quantity: 2, options:{line_item_seats_attributes: @line_item_seats_attributes, date: today})
            error = result.error.value.errors.first
            expect(result.success?).to eq false
            expect(error.options[:message]).to eq "Some seats are already booked"
          end
          it "error when at least one seat is already booked when checking out" do
            order1.update(state: :cart)
            Spree::Cart::AddItem.call(order: order3, variant: phnom_penh_to_siem_reap_by_airbus.master, quantity: 2, options:{line_item_seats_attributes: @line_item_seats_attributes, date: today})
            order1.update(state: :complete)
            expect { order3.next! }.to raise_error(StateMachines::InvalidTransition)
          end
        end

        context "success when all seats are available" do
          let(:selected_seats) {[ arb_f2_seat, arb_f3_seat, arb_f4_seat]}
          it "success when all seats are available" do
            result = Spree::Cart::AddItem.call(order: order2, variant: phnom_penh_to_siem_reap_by_airbus.master, quantity: 3, options:{line_item_seats_attributes: @line_item_seats_attributes, date: today})
            expect(result.success?).to eq true
            expect(result.error).to eq nil
          end
        end
      end

      context "not allow seat selection" do
        let!(:order1) { create(:order, state: :complete) }
        let!(:line_item1) {create(:line_item, quantity: 10, product:sihanoukville_to_koh_rong_by_ferry, order: order1, date: today)}
        let!(:order2) { create(:order, state: :cart) }
        let!(:order3) { create(:order, state: :payment) }
        it "error when quantity is more than available seats" do
          result = Spree::Cart::AddItem.call(order: order2, variant: sihanoukville_to_koh_rong_by_ferry.master, quantity: 11, options:{date: today})
          error = result.error.value.errors.first
          expect(result.success?).to eq false
          expect(error.options[:message]).to eq "exceeded available quantity"
        end
        it "success when quantity is less than or equal available seats" do
          result  = Spree::Cart::AddItem.call(order: order2, variant: sihanoukville_to_koh_rong_by_ferry.master, quantity: 10, options:{date: today})

          expect(result.success?).to eq true
          expect(result.error).to eq nil
        end
        it "error when quantity is more than available seats when checking out" do
          Spree::Cart::AddItem.call(order: order2, variant: sihanoukville_to_koh_rong_by_ferry.master, quantity: 10, options:{date: today})
          Spree::Cart::AddItem.call(order: order3, variant: sihanoukville_to_koh_rong_by_ferry.master, quantity: 10, options:{date: today})
          order2.update(state: :complete)
          expect { order3.next! }.to raise_error(StateMachines::InvalidTransition)
        end
      end
    end
  end
end
