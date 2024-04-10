require 'spec_helper'

RSpec.describe Spree::Price, type: :model do
  describe 'associations' do
    it { should belong_to(:priceable).required(true) }
    it { should belong_to(:variant).required(false) }
  end

  describe '#price_including_vat_for' do
    let(:price_options) { { tax_zone: ::Spree::Zone.default_tax } }

    subject { create(:price, priceable: priceable, amount: 10) }

    context 'when priceable is variant' do
      let(:priceable) { build(:variant) }

      it 'calls gross_amount with tax category from priceable' do
        expect(subject).to receive(:gross_amount).with(subject.price, { tax_category: priceable.tax_category }).and_call_original

        result = subject.price_including_vat_for({})

        expect(result).to eq 10
      end
    end

    context 'when priceable is pricing rate' do
      let(:variant) { build(:variant) }
      let(:priceable) { build(:cm_pricing_rate, rateable: variant) }

      it 'calls gross_amount with tax category from variant of priceable' do
        expect(subject).to receive(:gross_amount).with(subject.price, { tax_category: variant.tax_category }).and_call_original

        result = subject.price_including_vat_for({})

        expect(result).to eq 10
      end
    end
  end

  describe '#compare_at_price_including_vat_for' do
    let(:priceable) { build(:variant) }

    subject { create(:price, priceable: priceable, amount: 10) }

    it 'call gross_amount and return money' do
      expect(subject).to receive(:gross_amount).with(subject.price, { tax_category: priceable.tax_category }).and_call_original

      result = subject.display_price_including_vat_for({})

      expect(result).to be_an_instance_of(::Spree::Money)
      expect(result.to_s).to eq "$10.00"
    end
  end
end
