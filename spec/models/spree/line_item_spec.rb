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
