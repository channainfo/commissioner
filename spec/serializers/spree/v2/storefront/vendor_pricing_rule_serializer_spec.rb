# frozen_string_literal: true

RSpec.describe SpreeCmCommissioner::V2::Storefront::VendorPricingRuleSerializer, type: :serializer do
  describe '.serializable_hash' do
    let(:vendor) { create(:vendor) }
    let(:pricing_rule) { create(:cm_vendor_pricing_rule, vendor: vendor) }

    context 'with attributes' do
      subject { described_class.new(pricing_rule).serializable_hash }

      it { expect(subject[:data][:attributes]).to include(:date_rule) }
      it { expect(subject[:data][:attributes]).to include(:operator) }
      it { expect(subject[:data][:attributes]).to include(:amount) }
      it { expect(subject[:data][:attributes]).to include(:length) }
      it { expect(subject[:data][:attributes]).to include(:position) }
      it { expect(subject[:data][:attributes]).to include(:active) }
      it { expect(subject[:data][:attributes]).to include(:free_cancellation) }
      it { expect(subject[:data][:attributes]).to include(:min_price_by_rule) }
      it { expect(subject[:data][:attributes]).to include(:max_price_by_rule) }
      it { expect(subject[:data][:attributes]).to include(:price_by_dates) }
    end
  end
end
