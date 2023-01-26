require 'spec_helper'

describe Spree::V2::Storefront::StockLocationSerializer, type: :serializer do
  let(:vendor) { create(:vendor) }
  let!(:stock_location) { create(:cm_stock_location, vendor: vendor) }

  subject { described_class.new(stock_location) }

  it { expect(subject.serializable_hash).to be_kind_of(Hash) }

  it 'returns right data attributes' do
    expect(subject.serializable_hash[:data].keys).to contain_exactly(:attributes, :id, :relationships, :type)
  end

  it 'returns right stock location attributes' do
    expect(subject.serializable_hash[:data][:attributes].keys).to contain_exactly(:lat, :lon, :name, :address1)
    expect(subject.serializable_hash[:data][:attributes][:lat]).to eq(0.0)
    expect(subject.serializable_hash[:data][:attributes][:lon]).to eq(0.0)
  end
end
