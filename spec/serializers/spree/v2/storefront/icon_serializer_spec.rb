require 'spec_helper'

describe Spree::V2::Storefront::IconSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:icon) { create(:icon) }

    subject { described_class.new(icon).serializable_hash }

    it 'returns exact attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :url
      )
    end

    it 'has no relationships' do
      expect(subject[:data][:relationships]).to eq nil
    end
  end

  describe ':url' do
    let!(:icon) { create(:icon) }

    subject { described_class.new(icon).serializable_hash }

    it 'return fully constructed url' do
      expect(subject[:data][:attributes][:url]).to start_with('http://localhost:3000/rails/active_storage/blobs/proxy')
    end
  end
end
