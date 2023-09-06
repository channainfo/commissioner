require 'spec_helper'

describe Spree::V2::Storefront::StockLocationSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:stock_location) { create(:cm_stock_location) }

    subject {
      described_class.new(stock_location, include: [
        :vendor
      ]).serializable_hash
    }

    it 'returns exact attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :lat,
        :lon,
        :address1,
        :reference
      )
    end

    it 'returns exact relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :vendor,
        :state
      )
    end
  end
end
