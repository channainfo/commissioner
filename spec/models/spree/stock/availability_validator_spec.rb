require 'spec_helper'

RSpec.describe Spree::Stock::AvailabilityValidator do
  context 'reservation?' do
    describe '#validate_reservation' do
      let!(:product) { create(:cm_accommodation_product, permanent_stock: 3) }

      context 'booked on 10th-12th: 0 left for 10th, 2 left for 11-12th' do
        let(:reservation1) { build(:order, state: :complete) }
        let(:reservation2) { build(:order, state: :complete) }

        let!(:line_item1) { create(:line_item, quantity: 3, order: reservation1, product: product, from_date: date('2023-01-10'), to_date: date('2023-01-11')) }
        let!(:line_item2) { create(:line_item, quantity: 1, order: reservation2, product: product, from_date: date('2023-01-11'), to_date: date('2023-01-13')) }

        it 'error when at least one day could not supply 3 quantity' do
          line_item = build(:line_item, quantity: 3, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date)
          described_class.new.send(:validate_reservation, line_item)

          expect(line_item.errors.full_messages).to eq ([
            "Quantity Rooms are not available on 2023-01-10",
            "Quantity Only 2 rooms available on 2023-01-11",
            "Quantity Only 2 rooms available on 2023-01-12"
          ])
        end

        it 'success when all day is available for 2 quantity' do
          line_item = build(:line_item, quantity: 2, product: product, from_date: '2023-01-11'.to_date, to_date: '2023-01-12'.to_date)
          described_class.new.send(:validate_reservation, line_item)

          expect(line_item.errors.size).to eq 0
        end
      end
    end
  end
  context 'seat_reservation?' do
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
        let!(:order2) { create(:order, state: :complete) }
        let!(:line_item1) {create(:line_item, booking_seats: [arb_f1_seat, arb_f2_seat], product:phnom_penh_to_siem_reap_by_airbus, order: order1, date: today)}
        let!(:line_item2) {create(:line_item, booking_seats: [arb_f3_seat, arb_f4_seat], product:phnom_penh_to_siem_reap_by_airbus, order: order2, date: today)}
        it "error when at least one seat is already booked" do
          line_item = build(:line_item, booking_seats: [arb_f3_seat, arb_f4_seat], product: phnom_penh_to_siem_reap_by_airbus, date: today)
          described_class.new.send(:validate_seats_reservation, line_item)

          expect(line_item.errors.full_messages).to eq (["Some seats are already booked"])
        end

        it "success when all seats are available" do
          line_item = build(:line_item, booking_seats: [arb_f3_seat, arb_f4_seat], product: phnom_penh_to_siem_reap_by_airbus, date: today+1.day)
          described_class.new.send(:validate_seats_reservation, line_item)
          expect(line_item.errors.size).to eq 0
        end
      end
      context "not allow seat selection" do
        let!(:order1) { create(:order, state: :complete) }
        let!(:order2) { create(:order, state: :complete) }
        let!(:line_item1) {create(:line_item, quantity: 10, product:sihanoukville_to_koh_rong_by_ferry, order: order1, date: today)}
        let!(:line_item2) {create(:line_item, quantity: 5, product:sihanoukville_to_koh_rong_by_ferry, order: order2, date: today)}
        it "error when quantity is more than available seats" do
          line_item =  build(:line_item, quantity: 6, product: sihanoukville_to_koh_rong_by_ferry, date: today)
          described_class.new.send(:validate_seats_reservation, line_item)
           expect(line_item.errors.full_messages).to eq (["Quantity exceeded available quantity"])
        end
        it "success when quantity is less than or equal available seats" do
          line_item = build(:line_item, quantity: 5, product: sihanoukville_to_koh_rong_by_ferry, date: today)
          described_class.new.send(:validate_seats_reservation, line_item)
          expect(line_item.errors.size).to eq 0
        end
      end
    end
  end
end
