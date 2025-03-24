require 'spec_helper'

RSpec.describe SpreeCmCommissioner::BookingServices::BaseService do
  let(:variant) { create(:variant) }
  let(:variant_id) { variant.id }
  let(:start_date) { Date.new(2025, 4, 1) }
  let(:end_date) { Date.new(2025, 4, 3) }
  let(:quantity) { 2 }
  let(:booking_query) { instance_double(SpreeCmCommissioner::BookingQuery) }

  subject { described_class.new(variant_id) }

  before do
    # Stub service_type to avoid the raise during initialization
    allow_any_instance_of(described_class).to receive(:service_type).and_return('test_service')
    allow(SpreeCmCommissioner::BookingQuery).to receive(:new).and_return(booking_query)
  end

  describe '#initialize' do
    it 'sets variant_id' do
      expect(subject.instance_variable_get(:@variant_id)).to eq(variant_id)
    end

    it 'initializes booking_query with correct parameters' do
      expect(SpreeCmCommissioner::BookingQuery).to receive(:new).with(
        variant_id: variant_id,
        service_type: 'test_service'
      )
      described_class.new(variant_id)
    end

    it 'sets booking_query instance variable' do
      expect(subject.instance_variable_get(:@booking_query)).to eq(booking_query)
    end
  end

  describe '#book_inventory' do
    it 'delegates to booking_query.book_inventory!' do
      expect(booking_query).to receive(:book_inventory!).with(start_date, end_date, quantity)
      subject.book_inventory(start_date, end_date, quantity)
    end

    context 'when booking succeeds' do
      before do
        allow(booking_query).to receive(:book_inventory!).and_return(true)
      end

      it 'returns true' do
        expect(subject.book_inventory(start_date, end_date, quantity)).to be true
      end
    end

    context 'when booking fails' do
      before do
        allow(booking_query).to receive(:book_inventory!).and_raise(StandardError, 'Not enough inventory')
      end

      it 'raises the error from booking_query' do
        expect {
          subject.book_inventory(start_date, end_date, quantity)
        }.to raise_error(StandardError, 'Not enough inventory')
      end
    end
  end

  describe '#service_type' do
    before do
      # Remove the stub for this specific test
      allow_any_instance_of(described_class).to receive(:service_type).and_call_original
    end

    it 'raises error when not overridden' do
      expect {
        subject.send(:service_type)
      }.to raise_error('Need to define from sub class')
    end
  end

  describe 'private readers' do
    it 'provides access to booking_query' do
      expect(subject.send(:booking_query)).to be_present
    end

    it 'provides access to service_type' do
      # Using the stubbed value from before block
      expect(subject.send(:service_type)).to eq('test_service')
    end
  end
end
