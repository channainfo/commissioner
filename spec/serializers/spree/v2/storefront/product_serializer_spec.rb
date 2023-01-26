# frozen_string_literal: true

RSpec.describe Spree::V2::Storefront::ProductSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:product) { create(:cm_product) }

    context 'with no include' do
      subject { described_class.new(product, params: {'store': product.stores.first}).serializable_hash }
      it { expect(subject[:data][:relationships]).to include(:promoted_option_types) }
    end
  end
end
