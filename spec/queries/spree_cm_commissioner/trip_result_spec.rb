require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TripResult do
  #vendor
  describe 'initialize' do
    it ' initialize with options' do
      options = {trip_id: 1, vendor_id: 1, vendor_name: 'Vet Airbus', route_name: 'Phnom Penh to Siem Reap by Vet Airbus'}
      result = described_class.new(options)
      p result.vendor_name
      expect(result.vendor_name).to eq('Vet Airbus')
      expect(result.trip_id).to eq(1)
    end
  end
  describe 'remaining_seats' do
    it 'returns the remaining seats' do
      options = {trip_id: 1, vendor_id: 1, total_sold: 10, total_seats: 20}
      result = described_class.new(options)
      expect(result.remaining_seats).to eq(10)
    end
  end
end
