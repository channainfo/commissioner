require 'spec_helper'

describe Spree::V2::Storefront::VariantSerializer, type: :serializer do
  let(:variant) { create(:cm_variant) }

  context 'with no include' do
    subject { described_class.new(variant).serializable_hash }

    it { expect(subject[:data][:attributes]).to include(:permanent_stock) }
  end
end
