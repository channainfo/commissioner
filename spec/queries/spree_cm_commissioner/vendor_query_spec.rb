require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorQuery do
  let(:phnom_penh) { create(:state, name: 'Phnom Penh') }
  let(:siem_reap)  { create(:state, name: 'Siem Reap') }
  let!(:phnom_penh_hotel) { create(:cm_vendor_with_product, name: 'Phnom Penh Hotel',       state_id: phnom_penh.id, permanent_stock: 20) }
  let!(:sokha_pp_hotel)   { create(:cm_vendor_with_product, name: 'Sokha Phnom Penh Hotel', state_id: phnom_penh.id, permanent_stock: 20) }
  let!(:angkor_hotel)     { create(:cm_vendor_with_product, name: 'Angkor Hotel',           state_id: siem_reap.id,  permanent_stock: 20) }
  let!(:siemreap_hotel)   { create(:cm_vendor_with_product, name: 'Siem Reap Hotel',        state_id: siem_reap.id,  permanent_stock: 20) }
  let(:order1) { create(:order) }
  let(:order2) { create(:order) }
  let(:booking_fields)   { [:vendor_id, :day, :total_booking] }
  let(:inventory_fields) { booking_fields + [:remaining, :total_inventory] }

  context 'book hotels with multiple dates' do
    let!(:line_item1) { book_room(order1, hotel: phnom_penh_hotel, quantity: 2,  from_date: date('2023_01_01'), to_date: date('2023_01_03')) }
    let!(:line_item2) { book_room(order1, hotel: phnom_penh_hotel, quantity: 3,  from_date: date('2023_01_01'), to_date: date('2023_01_09')) }
    let!(:line_item3) { book_room(order2, hotel: phnom_penh_hotel, quantity: 6,  from_date: date('2023_01_03'), to_date: date('2023_01_07')) }

    let!(:line_item4) { book_room(order1, hotel: sokha_pp_hotel,   quantity: 3,  from_date: date('2023_01_01'), to_date: date('2023_01_08')) }
    let!(:line_item5) { book_room(order2, hotel: sokha_pp_hotel,   quantity: 7,  from_date: date('2023_01_07'), to_date: date('2023_01_10')) }
    let!(:line_item6) { book_room(order2, hotel: sokha_pp_hotel,   quantity: 9,  from_date: date('2023_01_15'), to_date: date('2023_01_20')) }

    context '.booked_vendors' do
      let(:records) { subject.booked_vendors.to_a }
      before(:each) do
        print_as_table(records, booking_fields)
      end

      # left case 1 day: 2022_12_30 (phnom_penh_hotel: 0, sokha_pp_hotel: 0)
      context 'query on 2022_12_30' do
        let(:subject) { described_class.new(from_date: date('2022_12_30'), to_date: date('2022_12_31'), province_id: phnom_penh.id) }

        it 'should return booking on 2022_12_30' do
          vendor_ids = records.map(&:vendor_id)

          expect(records.size).to eq 0
          expect(vendor_ids.sort).to eq []
        end
      end

      # left case: 2022_12_29 to 2023_01_02 (phnom_penh_hotel: 2+3, sokha_pp_hotel: 3)
      context 'query between 2022_12_29 to 2023_01_02' do
        let(:subject) { described_class.new(from_date: date('2022_12_29'), to_date: date('2023_01_02'), province_id: phnom_penh.id) }

        it 'should count hotel result' do
          expect(records.size).to eq 2
        end

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.uniq.sort).to eq([phnom_penh_hotel.id, sokha_pp_hotel.id].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find_all { |r| r.vendor_id == phnom_penh_hotel.id }

          expect(hotel.find { |r| r.day == date('2022_12_29') }).to be_nil
          expect(hotel.find { |r| r.day == date('2022_12_30') }).to be_nil
          expect(hotel.find { |r| r.day == date('2022_12_31') }).to be_nil
          expect(hotel.find { |r| r.day == date('2023_01_01') }.total_booking.to_i).to eq (line_item1.quantity + line_item2.quantity)
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find_all { |r| r.vendor_id == sokha_pp_hotel.id }

          expect(hotel.find { |r| r.day == date('2022_12_29') }).to be_nil
          expect(hotel.find { |r| r.day == date('2022_12_30') }).to be_nil
          expect(hotel.find { |r| r.day == date('2022_12_31') }).to be_nil
          expect(hotel.find { |r| r.day == date('2023_01_01') }.total_booking.to_i).to eq line_item4.quantity
        end
      end

      # middle case 1 day: 2023_01_03 (phnom_penh_hotel: 2+3+6, sokha_pp_hotel: 3)
      context 'query on 2023_01_03' do
        let(:subject) { described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_04'), province_id: phnom_penh.id) }

        it 'should count hotel result' do
          expect(records.size).to eq 2
        end

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.uniq.sort).to eq([phnom_penh_hotel.id, sokha_pp_hotel.id].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find_all { |r| r.vendor_id == phnom_penh_hotel.id }
          expect(hotel.find { |r| r.day == date('2023_01_03') }.total_booking.to_i).to eq (line_item1.quantity + line_item2.quantity + line_item3.quantity)
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find_all { |r| r.vendor_id == sokha_pp_hotel.id }
          expect(hotel.find { |r| r.day == date('2023_01_03') }.total_booking.to_i).to eq (line_item4.quantity)
        end
      end

      # middle case: 2023_01_04 to 2023_01_08 (phnom_penh_hotel: 3+6, sokha_pp_hotel: 3+7)
      context 'query between 2023_01_04 to 2023_01_08' do
        let(:subject) { described_class.new(from_date: date('2023_01_04'), to_date: date('2023_01_08'), province_id: phnom_penh.id) }

        it 'should count hotel result' do
          expect(records.size).to eq 8
        end

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.uniq.sort).to eq([phnom_penh_hotel.id, sokha_pp_hotel.id].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find_all { |r| r.vendor_id == phnom_penh_hotel.id }

          expect(hotel.size).to eq 4
          expect(hotel.find { |r| r.day == date('2023_01_04') }.total_booking.to_i).to eq (line_item2.quantity + line_item3.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_05') }.total_booking.to_i).to eq (line_item2.quantity + line_item3.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_06') }.total_booking.to_i).to eq (line_item2.quantity + line_item3.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_07') }.total_booking.to_i).to eq (line_item2.quantity + line_item3.quantity)
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find_all { |r| r.vendor_id == sokha_pp_hotel.id }

          expect(hotel.size).to eq 4
          expect(hotel.find { |r| r.day == date('2023_01_04') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_05') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_06') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_07') }.total_booking.to_i).to eq (line_item4.quantity + line_item5.quantity)
        end
      end

      # middle case: 2023_01_09 to 2023_01_16 (phnom_penh_hotel: 3, sokha_pp_hotel: 9)
      context 'query between 2023_01_09 to 2023_01_16' do
        let(:subject) { described_class.new(from_date: date('2023_01_09'), to_date: date('2023_01_16'), province_id: phnom_penh.id) }

        it 'should count hotel result' do
          expect(records.size).to eq 4
        end

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.uniq.sort).to eq([phnom_penh_hotel.id, sokha_pp_hotel.id].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find_all { |r| r.vendor_id == phnom_penh_hotel.id }

          expect(hotel.size).to eq 1
          expect(hotel.find { |r| r.day == date('2023_01_09') }.total_booking.to_i).to eq (line_item2.quantity)
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find_all { |r| r.vendor_id == sokha_pp_hotel.id }

          expect(hotel.size).to eq 3
          expect(hotel.find { |r| r.day == date('2023_01_09') }.total_booking.to_i).to eq (line_item5.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_10') }.total_booking.to_i).to eq (line_item5.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_15') }.total_booking.to_i).to eq (line_item6.quantity)
        end
      end

      # middle case: 2023_01_10 to 2023_01_12 (phnom_penh_hotel: 0, sokha_pp_hotel: 7)
      context 'query between 2023_01_10 to 2023_01_12' do
        let(:subject) { described_class.new(from_date: date('2023_01_10'), to_date: date('2023_01_12'), province_id: phnom_penh.id) }

        it 'should count hotel result' do
          expect(records.size).to eq 1
        end

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.uniq.sort).to eq([sokha_pp_hotel.id].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find_all { |r| r.vendor_id == phnom_penh_hotel.id }

          expect(hotel.size).to eq 0
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find_all { |r| r.vendor_id == sokha_pp_hotel.id }

          expect(hotel.size).to eq 1
          expect(hotel.find { |r| r.day == date('2023_01_10') }.total_booking.to_i).to eq (line_item5.quantity)
        end
      end

       # right case: 2023_01_20 to 2023_01_22 (phnom_penh_hotel: 0, sokha_pp_hotel: 9)
       context 'query between 2023_01_20 to 2023_01_22' do
        let(:subject) { described_class.new(from_date: date('2023_01_20'), to_date: date('2023_01_25'), province_id: phnom_penh.id) }

        it 'should count hotel result' do
          expect(records.size).to eq 1
        end

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.uniq.sort).to eq([sokha_pp_hotel.id].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find_all { |r| r.vendor_id == phnom_penh_hotel.id }

          expect(hotel.size).to eq 0
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find_all { |r| r.vendor_id == sokha_pp_hotel.id }

          expect(hotel.size).to eq 1
          expect(hotel.find { |r| r.day == date('2023_01_20') }.total_booking.to_i).to eq (line_item6.quantity)
        end
      end

      # all : 2022_12_29 to 2023_01_15 (phnom_penh_hotel: 2+3+6, sokha_pp_hotel: 3+7)
      context 'query between 2022_12_29 to 2023_01_15' do
        let(:subject) { described_class.new(from_date: date('2022_12_29'), to_date: date('2023_01_15'), province_id: phnom_penh.id) }

        it 'should count hotel result' do
          expect(records.size).to eq 19
        end

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.uniq.sort).to eq([phnom_penh_hotel.id, sokha_pp_hotel.id].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find_all { |r| r.vendor_id == phnom_penh_hotel.id }

          expect(hotel.size).to eq 9
          expect(hotel.find { |r| r.day == date('2023_01_01') }.total_booking.to_i).to eq (line_item1.quantity + line_item2.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_02') }.total_booking.to_i).to eq (line_item1.quantity + line_item2.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_03') }.total_booking.to_i).to eq (line_item1.quantity + line_item2.quantity + line_item3.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_04') }.total_booking.to_i).to eq (line_item2.quantity + line_item3.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_05') }.total_booking.to_i).to eq (line_item2.quantity + line_item3.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_06') }.total_booking.to_i).to eq (line_item2.quantity + line_item3.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_07') }.total_booking.to_i).to eq (line_item2.quantity + line_item3.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_08') }.total_booking.to_i).to eq (line_item2.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_09') }.total_booking.to_i).to eq (line_item2.quantity)
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find_all { |r| r.vendor_id == sokha_pp_hotel.id }

          expect(hotel.size).to eq 10
          expect(hotel.find { |r| r.day == date('2023_01_01') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_02') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_03') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_04') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_05') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_06') }.total_booking.to_i).to eq (line_item4.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_07') }.total_booking.to_i).to eq (line_item4.quantity + line_item5.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_08') }.total_booking.to_i).to eq (line_item4.quantity + line_item5.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_09') }.total_booking.to_i).to eq (line_item5.quantity)
          expect(hotel.find { |r| r.day == date('2023_01_10') }.total_booking.to_i).to eq (line_item5.quantity)
        end
      end

      # future : 2023_02_12 to 2023_02_15 (phnom_penh_hotel: 0, sokha_pp_hotel: 0)
      context 'query between 2023_02_12 to 2023_02_15' do
        let(:subject) { described_class.new(from_date: date('2023_02_12'), to_date: date('2023_02_15'), province_id: phnom_penh.id) }

        it 'should count hotel result' do
          expect(records.size).to eq 0
        end

        it 'list id of phnom_penh_hotel and sokha_pp_hotel' do
          vendor_ids = records.map(&:vendor_id)
          expect(vendor_ids.uniq.sort).to eq([].sort)
        end

        it 'total_booking of phnom_penh_hotel' do
          hotel = records.find_all { |r| r.vendor_id == phnom_penh_hotel.id }

          expect(hotel.size).to eq 0
        end

        it 'total_booking of sokha_pp_hotel' do
          hotel = records.find_all { |r| r.vendor_id == sokha_pp_hotel.id }

          expect(hotel.size).to eq 0
        end
      end
    end

    context '.max_booked_vendor_sql' do
      let(:records) { execute_sql(subject.max_booked_vendor_sql).to_a }
      before(:each) do
        print_as_table(records, booking_fields)
      end

      context 'query between 2022_12_12 and 2022_12_15' do
        let(:subject) { described_class.new(from_date: date('2022_12_12'), to_date: date('2022_12_15'), province_id: phnom_penh.id)}

        it 'includes all booked hotels in phnom_penh' do
          vendor_ids = records.map { |r| r['vendor_id'] }
          expect(vendor_ids).to eq []
        end

        it 'total_booking of phnom_penh_hotel' do
          record = records.find { |record| record['vendor_id'] == phnom_penh_hotel.id }
          expect(record).to be_nil
        end

        it 'total_booking of sokha_pp_hotel' do
          record = records.find { |record| record['vendor_id'] == sokha_pp_hotel.id }
          expect(record).to be_nil
        end
      end

      context 'query on 2023_01_01' do
        let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: phnom_penh.id)}

        it 'includes all booked hotels in phnom_penh' do
          vendor_ids = records.map { |r| r['vendor_id'] }
          expect(vendor_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
        end

        it 'total_booking of phnom_penh_hotel' do
          record = records.find { |record| record['vendor_id'] == phnom_penh_hotel.id }
          expect(record['total_booking'].to_i).to eq (line_item1.quantity + line_item2.quantity)
        end

        it 'total_booking of sokha_pp_hotel' do
          record = records.find { |record| record['vendor_id'] == sokha_pp_hotel.id }
          expect(record['total_booking']).to eq line_item4.quantity
        end
      end

      context 'query between 2023_01_03 and 2023_01_06' do
        let(:subject) { described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_06'), province_id: phnom_penh.id)}

        it 'total_booking of phnom_penh_hotel' do
          record = records.find { |record| record['vendor_id'] == phnom_penh_hotel.id }
          expect(record['total_booking'].to_i).to eq (line_item1.quantity + line_item2.quantity + line_item3.quantity)
        end

        it 'total_booking of sokha_pp_hotel' do
          record = records.find { |record| record['vendor_id'] == sokha_pp_hotel.id }
          expect(record['total_booking']).to eq (line_item4.quantity)
        end
      end

      context 'query between 2023_01_05 and 2023_01_11' do
        let(:subject) { described_class.new(from_date: date('2023_01_05'), to_date: date('2023_01_11'), province_id: phnom_penh.id)}

        it 'total_booking of phnom_penh_hotel' do
          record = records.find { |record| record['vendor_id'] == phnom_penh_hotel.id }
          expect(record['total_booking'].to_i).to eq (line_item2.quantity + line_item3.quantity)
        end

        it 'total_booking of sokha_pp_hotel' do
          record = records.find { |record| record['vendor_id'] == sokha_pp_hotel.id }
          expect(record['total_booking']).to eq (line_item4.quantity + line_item5.quantity)
        end
      end

      context 'query between 2023_01_10 and 2023_01_12' do
        let(:subject) { described_class.new(from_date: date('2023_01_10'), to_date: date('2023_01_12'), province_id: phnom_penh.id)}

        it 'includes all booked hotels in phnom_penh' do
          vendor_ids = records.map { |r| r['vendor_id'] }
          expect(vendor_ids.sort).to eq [sokha_pp_hotel.id].sort
        end

        it 'total_booking of phnom_penh_hotel' do
          record = records.find { |record| record['vendor_id'] == phnom_penh_hotel.id }
          expect(record).to be_nil
        end

        it 'total_booking of sokha_pp_hotel' do
          record = records.find { |record| record['vendor_id'] == sokha_pp_hotel.id }
          expect(record['total_booking']).to eq (line_item5.quantity)
        end
      end

      context 'query between 2023_01_12 and 2023_01_15' do
        let(:subject) { described_class.new(from_date: date('2023_01_12'), to_date: date('2023_01_15'), province_id: phnom_penh.id)}

        it 'includes all booked hotels in phnom_penh' do
          vendor_ids = records.map { |r| r['vendor_id'] }
          expect(vendor_ids).to eq []
        end

        it 'total_booking of phnom_penh_hotel' do
          record = records.find { |record| record['vendor_id'] == phnom_penh_hotel.id }
          expect(record).to be_nil
        end

        it 'total_booking of sokha_pp_hotel' do
          record = records.find { |record| record['vendor_id'] == sokha_pp_hotel.id }
          expect(record).to be_nil
        end
      end
    end

    context '.vendor_with_available_inventory' do
      let(:records) { subject.vendor_with_available_inventory }
      before(:each) do
        print_as_table(records, inventory_fields)
      end

      # left case 1 day: 2022_12_30 (phnom_penh_hotel: 0, sokha_pp_hotel: 0)
      context 'query on 2022_12_30' do
        let(:subject) { described_class.new(from_date: date('2022_12_30'), to_date: date('2022_12_31'), province_id: phnom_penh.id) }

        it 'includes all phnom_penh hotels' do
          hotel_ids = records.map(&:id)
          expect(hotel_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
        end

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 0, remaining: 20)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 0, remaining: 20)
        end
      end

      # left case: 2022_12_29 to 2022_12_31 (phnom_penh_hotel: 0, sokha_pp_hotel: 0)
      context 'query between 2022_12_29 to 2022_12_31' do
        let(:subject) { described_class.new(from_date: date('2022_12_29'), to_date: date('2022_12_31'), province_id: phnom_penh.id) }

        it 'includes all phnom_penh hotels' do
          hotel_ids = records.map(&:id)
          expect(hotel_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
        end

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 0, remaining: 20)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 0, remaining: 20)
        end
      end

      # left case: 2023_01_01 (phnom_penh_hotel: 2+3, sokha_pp_hotel: 3)
      context 'query on 2023_01_01' do
        let(:subject) { described_class.new(from_date: date('2023_01_01'), to_date: date('2023_01_02'), province_id: phnom_penh.id) }

        it 'includes all phnom_penh hotels' do
          hotel_ids = records.map(&:id)
          expect(hotel_ids.sort).to eq [phnom_penh_hotel.id, sokha_pp_hotel.id].sort
        end

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 5, remaining: 15)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 3, remaining: 17)
        end
      end

      # middle case 1 day: 2023_01_03 (phnom_penh_hotel: 2+3+6, sokha_pp_hotel: 3)
      context 'query on 2023_01_03' do
        let(:subject) { described_class.new(from_date: date('2023_01_03'), to_date: date('2023_01_04'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 11, remaining: 9)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 3, remaining: 17)
        end
      end

      # middle case: 2023_01_04 to 2023_01_09 (phnom_penh_hotel: 3+6, sokha_pp_hotel: 3+7)
      context 'query on between 2023_01_04 and 2023_01_09' do
        let(:subject) { described_class.new(from_date: date('2023_01_04'), to_date: date('2023_01_09'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 9, remaining: 11)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 10, remaining: 10)
        end
      end

      # middle case: 2023_01_09 to 2023_01_16 (phnom_penh_hotel: 3, sokha_pp_hotel: 9)
      context 'query on between 2023_01_09 and 2023_01_16' do
        let(:subject) { described_class.new(from_date: date('2023_01_09'), to_date: date('2023_01_16'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 3, remaining: 17)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 9, remaining: 11)
        end
      end

      # middle case: 2023_01_08 to 2023_01_20 (phnom_penh_hotel: 3, sokha_pp_hotel: 10)
      context 'query on between 2023_01_08 and 2023_01_20' do
        let(:subject) { described_class.new(from_date: date('2023_01_08'), to_date: date('2023_01_20'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 3, remaining: 17)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 10, remaining: 10)
        end
      end

      # right case: 2023_01_10 to 2023_01_15 (phnom_penh_hotel: 0, sokha_pp_hotel: 7)
      context 'query on between 2023_01_10 and 2023_01_15' do
        let(:subject) { described_class.new(from_date: date('2023_01_10'), to_date: date('2023_01_15'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 0, remaining: 20)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 7, remaining: 13)
        end
      end

      # all : 2022_12_30 to 2023_01_15 (phnom_penh_hotel: 2+3+6, sokha_pp_hotel: 3+7)
      context 'query on between 2022_12_30 and 2023_01_15' do
        let(:subject) { described_class.new(from_date: date('2022_12_30'), to_date: date('2023_01_15'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 11, remaining: 9)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 10, remaining: 10)
        end
      end

      # future : 2023_02_12 to 2023_02_15 (phnom_penh_hotel: 0, sokha_pp_hotel: 0)
      context 'query on between 2023_02_12 and 2023_02_15' do
        let(:subject) { described_class.new(from_date: date('2023_02_12'), to_date: date('2023_02_15'), province_id: phnom_penh.id) }

        it 'inventory of phnom_penh_hotel' do
          hotel = records.find { |r| r.id == phnom_penh_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 0, remaining: 20)
        end

        it 'inventory of sokha_pp_hotel' do
          hotel = records.find { |r| r.id == sokha_pp_hotel.id }
          expect_inventory(hotel, total_inventory: 20, total_booking: 0, remaining: 20)
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