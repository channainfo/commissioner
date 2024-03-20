require 'spec_helper'

describe Spree::V2::Storefront::OptionTypeSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:option_type) { create(:option_type, attr_type: "string") }

    subject {
      described_class.new(option_type, include: [
        :option_values
      ]).serializable_hash
    }

    it 'returns exact attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :name,
        :presentation,
        :position,
        :public_metadata,
        :kind,
        :attr_type,
        :promoted,
        :hidden
      )
    end

    it 'returns exact relationships' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :option_values
      )
    end
  end
end
