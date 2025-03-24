require 'spec_helper'

RSpec.describe SpreeCmCommissioner::BookingServices::AccommodationService do
  let(:variant_id) { 123 }
  let(:check_in) { Date.new(2025, 4, 1) }
  let(:check_out) { Date.new(2025, 4, 3) }
  let(:num_room) { 2 }

  subject { described_class.new(variant_id: variant_id) }

  describe '#book' do
    context 'with valid dates' do
      before do
        allow(subject).to receive(:book_inventory).and_return(true)
      end

      it 'calls book_inventory with correct parameters' do
        expect(subject).to receive(:book_inventory).with(check_in, check_out, num_room)
        subject.book(check_in, check_out, num_room)
      end

      it 'returns the result of book_inventory' do
        expect(subject.book(check_in, check_out, num_room)).to be true
      end
    end

    context 'with invalid dates' do
      context 'when check_in is nil' do
        it 'raises ArgumentError' do
          expect {
            subject.book(nil, check_out, num_room)
          }.to raise_error(ArgumentError, 'Check-out date must be after check-in date')
        end
      end

      context 'when check_out is nil' do
        it 'raises ArgumentError' do
          expect {
            subject.book(check_in, nil, num_room)
          }.to raise_error(ArgumentError, 'Check-out date must be after check-in date')
        end
      end

      context 'when check_out is before check_in' do
        let(:invalid_check_out) { Date.new(2025, 3, 31) }

        it 'raises ArgumentError' do
          expect {
            subject.book(check_in, invalid_check_out, num_room)
          }.to raise_error(ArgumentError, 'Check-out date must be after check-in date')
        end
      end

      context 'when check_out equals check_in' do
        it 'raises ArgumentError' do
          expect {
            subject.book(check_in, check_in, num_room)
          }.to raise_error(ArgumentError, 'Check-out date must be after check-in date')
        end
      end
    end
  end

  describe '#service_type' do
    it 'returns "accommodation"' do
      expect(subject.send(:service_type)).to eq('accommodation')
    end
  end

  describe '#validate_dates' do
    it 'passes with valid dates' do
      expect {
        subject.send(:validate_dates, check_in, check_out)
      }.not_to raise_error
    end

    it 'raises ArgumentError with invalid dates' do
      expect {
        subject.send(:validate_dates, check_out, check_in)
      }.to raise_error(ArgumentError, 'Check-out date must be after check-in date')
    end
  end
end
