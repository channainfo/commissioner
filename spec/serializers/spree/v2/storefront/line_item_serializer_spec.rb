# frozen_string_literal: true

RSpec.describe Spree::V2::Storefront::LineItemSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:line_item) { create(:cm_line_item) }

    context 'with no include' do
      subject {
        described_class.new(line_item).serializable_hash
      }

      it { expect(subject[:data][:attributes]).to include(:name) }
      it { expect(subject[:data][:attributes]).to include(:quantity) }
      it { expect(subject[:data][:attributes]).to include(:from_date) }
      it { expect(subject[:data][:attributes]).to include(:to_date) }

      it { expect(subject[:data][:relationships]).to include(:variant) }
      it { expect(subject[:data][:relationships]).to include(:digital_links) }
      it { expect(subject[:data][:relationships]).to include(:vendor) }
    end
  end
end
