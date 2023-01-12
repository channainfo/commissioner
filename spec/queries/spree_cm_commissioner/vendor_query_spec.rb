require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorQuery do
  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let(:siem_reap)  { create(:state, name: 'Siem Reap') }
  let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel',       state_id: phnom_penh.id, permanent_stock: 10) }
  let!(:sokha_pp_hotel)   { create(:cm_vendor_with_product, name: 'Sokha Phnom Penh Hotel', state_id: phnom_penh.id, permanent_stock: 10) }
  let!(:angkor_hotel)     { create(:cm_vendor_with_product, name: 'Angkor Hotel',           state_id: siem_reap.id,  permanent_stock: 10) }
  let!(:siemreap_hotel)   { create(:cm_vendor_with_product, name: 'Siem Reap Hotel',        state_id: siem_reap.id,  permanent_stock: 10) }
  let(:order1) { create(:order) }
  let(:order2) { create(:order) }
  let(:booking_fields)   { [:vendor_id, :day, :total_booking] }
  let(:inventory_fields) { booking_fields + [:remaining] }


  context 'no booked hotels' do
    let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_03'), province_id: phnom_penh.id) }

    it '.booked_vendors' do
      records = subject.booked_vendors.to_a
      expect(records.size).to eq 0
    end

    it '.max_booked_vendor_sql' do
      records = execute_sql(subject.max_booked_vendor_sql)
      expect(records.size).to eq 0
    end

    context '.vendor_with_available_inventory' do
      let(:records) { subject.vendor_with_available_inventory }

      it 'includes all phnom_penh hotels' do
        hotel_ids = records.map(&:id)  # vendor_id is not working
        expect(hotel_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
      end

      it 'inventory of phnom_penh_hotel' do
        hotel = records.find { |r| r.id == phnom_penh_hotel.id }
        expect_inventory(hotel, total_inventory: 10, total_booking: nil, remaining: nil)
      end

      it 'inventory of sokha_pp_hotel' do
        hotel = records.find { |r| r.id == sokha_pp_hotel.id }
        expect_inventory(hotel, total_inventory: 10, total_booking: nil, remaining: nil)
      end
    end
  end

  context 'book one hotel with 1 day on 2023_01_01' do
    let!(:make_order) { book_room(order1, hotel: phnom_penh_hotel, quantity: 2,  from_date: date('2023_01_01'), to_date: date('2023_01_01')) }
    let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: phnom_penh.id) }

    context '.booked_vendors' do
      let(:records) { subject.booked_vendors.to_a }

      it 'show only booked hotel' do
        print_as_table(records, booking_fields)
        vendor_ids = records.map(&:vendor_id)
        expect(vendor_ids).to eq [phnom_penh_hotel.id]
      end

      it 'booked_date on 2023_01_01' do
        dates = records.map &:day
        expect(dates).to eq [date('2023_01_01')]
      end

      it 'total_booking on 2023_01_01' do
        expect(records.first.total_booking).to eq 2
      end
    end

    context '.max_booked_vendor_sql' do
      let(:records) { execute_sql(subject.max_booked_vendor_sql).to_a }
      let(:record) { records.first }

      it 'has only on hotel' do
        expect(records.size).to eq 1
        expect(record['vendor_id']).to eq phnom_penh_hotel.id
      end

      it 'has total_booking' do
        expect(record['total_booking']).to eq 2
      end

      it 'has day' do
        expect(record['day']).to eq date('2023_01_01')
      end
    end

    context '.vendor_with_available_inventory' do
      let(:records) { subject.vendor_with_available_inventory }

      it 'includes all phnom_penh hotels' do
        hotel_ids = records.map(&:id)
        expect(hotel_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
      end

      it 'inventory of phnom_penh_hotel' do
        hotel = records.find { |r| r.id == phnom_penh_hotel.id }
        expect_inventory(hotel, total_inventory: 10, total_booking: 2, remaining: 8)
      end

      it 'inventory of sokha_pp_hotel' do
        hotel = records.find { |r| r.id == sokha_pp_hotel.id }
        expect_inventory(hotel, total_inventory: 10, total_booking: nil, remaining: nil)
      end
    end
  end

  context 'book one hotel with multiple dates' do
    let!(:make_order) {
      book_room(order1, hotel: phnom_penh_hotel, quantity: 2,  from_date: date('2023_01_01'), to_date: date('2023_01_03'))
      book_room(order1, hotel: phnom_penh_hotel, quantity: 3,  from_date: date('2023_01_01'), to_date: date('2023_01_08'))
      book_room(order2, hotel: phnom_penh_hotel, quantity: 5,  from_date: date('2023_01_03'), to_date: date('2023_01_07'))
    }

    context '.booked_vendors' do
      let(:records) { @subject.booked_vendors.to_a }

      it 'total_booking on 2023_01_30' do
        @subject = described_class.new(from_date: date('2023_01_30'), to_date: date('2023_01_31'), province_id: phnom_penh.id)
        expect(records.size).to eq 0
      end

      it 'total_booking on 2023_01_01' do
        @subject = described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: phnom_penh.id)
        print_as_table(records, booking_fields)
        expect(records.first.total_booking).to eq 5
      end

      it 'total_booking on 2023_01_03' do
        @subject = described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_04'), province_id: phnom_penh.id)
        print_as_table(records, booking_fields)

        expect(records.first.total_booking).to eq 10
      end

      it 'total_booking between 2023_01_01 and 2023_01_03' do
        @subject = described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_06'), province_id: phnom_penh.id)
        print_as_table(records, booking_fields)

        expect(records.find { |r| r.day == date('2023_01_01') }.total_booking).to eq 5
        expect(records.find { |r| r.day == date('2023_01_02') }.total_booking).to eq 5
        expect(records.find { |r| r.day == date('2023_01_03') }.total_booking).to eq 10
        expect(records.find { |r| r.day == date('2023_01_04') }.total_booking).to eq 8
        expect(records.find { |r| r.day == date('2023_01_05') }.total_booking).to eq 8
      end
    end

    context '.max_booked_vendor_sql' do
      let(:records) { execute_sql(@subject.max_booked_vendor_sql).to_a }
      let(:record) { records.first }

      it 'total_booking on 2023_01_01' do
        @subject = described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: phnom_penh.id)
        expect(record['total_booking']).to eq 5
      end

      it 'total_booking on 2023_01_03' do
        @subject = described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_04'), province_id: phnom_penh.id)
        expect(record['total_booking']).to eq 10
      end

      it 'total_booking between 2023_01_01 and 2023_01_05' do
        @subject = described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_06'), province_id: phnom_penh.id)
        expect(record['total_booking']).to eq 10
        expect(record['day']).to eq date('2023_01_03')
      end
    end

    context '.vendor_with_available_inventory' do
      let(:records) { subject.vendor_with_available_inventory }

      context 'query on 2023_01_01' do
        let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: phnom_penh.id) }

        it 'includes all phnom_penh hotels' do
          hotel_ids = records.map(&:id)
          expect(hotel_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
        end

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 5, remaining: 5)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: nil, remaining: nil)
        end
      end

      context 'query on 2023_01_03' do
        let(:subject) { described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_04'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 10, remaining: 0)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: nil, remaining: nil)
        end
      end

      context 'query on between 2023_01_01 and 2023_01_05' do
        let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_06'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 10, remaining: 0)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: nil, remaining: nil)
        end
      end
    end
  end

  context 'book two hotel with multiple dates' do
    let!(:make_order) {
      book_room(order1, hotel: phnom_penh_hotel, quantity: 2,  from_date: date('2023_01_01'), to_date: date('2023_01_05'))
      book_room(order2, hotel: phnom_penh_hotel, quantity: 5,  from_date: date('2023_01_03'), to_date: date('2023_01_04'))
      book_room(order2, hotel: phnom_penh_hotel, quantity: 5,  from_date: date('2023_01_10'), to_date: date('2023_01_14'))


      book_room(order1, hotel: sokha_pp_hotel,   quantity: 3,  from_date: date('2023_01_01'), to_date: date('2023_01_08'))
      book_room(order2, hotel: sokha_pp_hotel,   quantity: 7,  from_date: date('2023_01_03'), to_date: date('2023_01_09'))
    }

    context '.booked_vendors' do
      let(:records) { subject.booked_vendors.to_a }

      context 'query on 2023_01_03' do
        let(:subject) { described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_04'), province_id: phnom_penh.id) }

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          print_as_table(records, booking_fields)
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.sort).to eq([phnom_penh_hotel.id, sokha_pp_hotel.id].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find { |r| r.vendor_id == phnom_penh_hotel.id }
          expect(hotel.total_booking).to eq 7
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find { |r| r.vendor_id == sokha_pp_hotel.id }
          expect(hotel.total_booking).to eq 10
        end
      end

      context 'query between 2023_01_03 and 2023_01_06' do
        let(:subject) { described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_07'), province_id: phnom_penh.id) }

        it 'total_bookings of phnom_penh_hotel' do
          phnom_penh_hotel_records = records.select { |r| r.vendor_id == phnom_penh_hotel.id }

          expect(phnom_penh_hotel_records.find { |r| r.day == date('2023_01_03') }.total_booking).to eq 7
          expect(phnom_penh_hotel_records.find { |r| r.day == date('2023_01_04') }.total_booking).to eq 7
          expect(phnom_penh_hotel_records.find { |r| r.day == date('2023_01_05') }.total_booking).to eq 2
          expect(phnom_penh_hotel_records.find { |r| r.day == date('2023_01_06') }).to be_nil
        end

        it 'total_booking of sokha_pp_hotel' do
          sokha_pp_records = records.select { |r| r.vendor_id == sokha_pp_hotel.id }
          expect(sokha_pp_records.find { |r| r.day == date('2023_01_03') }.total_booking).to eq 10
          expect(sokha_pp_records.find { |r| r.day == date('2023_01_04') }.total_booking).to eq 10
          expect(sokha_pp_records.find { |r| r.day == date('2023_01_05') }.total_booking).to eq 10
          expect(sokha_pp_records.find { |r| r.day == date('2023_01_06') }.total_booking).to eq 10
        end
      end
    end

    context '.max_booked_vendor_sql' do
      let(:records) { execute_sql(subject.max_booked_vendor_sql).to_a }

      context 'query on 2023_01_01' do
        let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: phnom_penh.id)}

        it 'includes all booked hotels in phnom_penh' do
          vendor_ids = records.map { |r| r['vendor_id'] }
          expect(vendor_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
        end

        it 'total_booking of phnom_penh_hotel' do
          record = records.find { |record| record['vendor_id'] == phnom_penh_hotel.id }
          expect(record['total_booking']).to eq 2
        end

        it 'total_booking of sokha_pp_hotel' do
          record = records.find { |record| record['vendor_id'] == sokha_pp_hotel.id }
          expect(record['total_booking']).to eq 3
        end
      end

      context 'query between 2023_01_05 and 2023_01_11' do
        let(:subject) { described_class.new(from_date: date('2023_01_05'), to_date: date('2023_01_11'), province_id: phnom_penh.id)}

        it 'total_booking of phnom_penh_hotel' do
          record = records.find { |record| record['vendor_id'] == phnom_penh_hotel.id }
          expect(record['total_booking']).to eq 5
        end

        it 'total_booking of sokha_pp_hotel' do
          record = records.find { |record| record['vendor_id'] == sokha_pp_hotel.id }
          expect(record['total_booking']).to eq 10
        end
      end
    end

    context '.vendor_with_available_inventory' do
      let(:records) { subject.vendor_with_available_inventory }

      context 'query on 2023_01_01' do
        let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: phnom_penh.id) }

        it 'includes all phnom_penh hotels' do
          hotel_ids = records.map(&:id)
          expect(hotel_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
        end

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 2, remaining: 8)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 3, remaining: 7)
        end
      end

      context 'query on 2023_01_03' do
        let(:subject) { described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_04'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 7, remaining: 3)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 10, remaining: 0)
        end
      end

      context 'query on between 2023_01_01 and 2023_01_05' do
        let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_06'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 7, remaining: 3)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 10, total_booking: 10, remaining: 0)
        end
      end
    end
  end

  context 'validate date range' do
    it 'is valid' do
      subject = described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_03'), province_id: phnom_penh.id)
      expect(subject).to be_valid
    end

    it 'is invalid if to_date < from_date' do
      subject = described_class.new(from_date: date('2023_01_02'), to_date: date('2023_01_01'), province_id: phnom_penh.id)

      expect(subject.valid?).to eq false
      expect(subject.errors[:date_range]).to include("To Date cannot be less than From Date")
    end

    it 'is invalid if date_range > 31 days' do
      subject = described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_01') + 32.days, province_id: phnom_penh.id)
      expect(subject.valid?).to eq false
      expect(subject.errors[:date_range]).to include("Duration must not be greater than 31 days")
    end
  end

  context '.date_list_sql' do
    it 'generates day series as 1 record' do
      subject = described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: siem_reap.id)
      records = execute_sql(subject.date_list_sql)
      print_as_table(records)

      sql_statement = "SELECT day FROM generate_series('2023-01-01'::date, '2023-01-01', '1 day') AS day"
      expect(subject.date_list_sql).to eq sql_statement
      expect(records.count).to eq 1
    end

    it 'generates day series as 2 records' do
      subject = described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_03'), province_id: siem_reap.id)
      records = execute_sql(subject.date_list_sql)
      print_as_table(records)

      sql_statement = "SELECT day FROM generate_series('2023-01-01'::date, '2023-01-02', '1 day') AS day"
      expect(subject.date_list_sql).to eq sql_statement
      expect(records.count).to eq 2
    end
  end

  private

  def book_room(order, hotel: , price: 100, quantity: , from_date:, to_date:)
    room = hotel.variants.first # vip, air
    order.line_items.create(vendor_id: hotel.id, price: price, quantity: quantity, from_date: from_date, to_date: to_date, variant_id: room.id)
  end

  def execute_sql(sql)
    ActiveRecord::Base.connection.execute(sql).to_a
  end

  def expect_inventory(hotel, total_inventory:, total_booking:, remaining:)
    expect(hotel.total_inventory).to eq total_inventory
    expect(hotel.total_booking).to   eq total_booking
    expect(hotel.remaining).to       eq remaining
  end
end