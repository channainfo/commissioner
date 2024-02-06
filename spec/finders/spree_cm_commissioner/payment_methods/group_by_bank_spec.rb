require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PaymentMethods::GroupByBank do
  let(:acleda_method_1) { create(:payment_method, position: 2, type: 'Spree::Gateway::Acleda') }
  let(:acleda_method_2) { create(:payment_method, position: 3, type: 'Spree::Gateway::Acleda') }
  let(:aba_method_1) { create(:payment_method, position: 4, type: 'Spree::Gateway::PaywayV2') }
  let(:aba_method_2) { create(:payment_method, position: 1, type: 'Spree::Gateway::PaywayV2') }

  let(:payment_methods) { [acleda_method_1, acleda_method_2, aba_method_1, aba_method_2] }
  let(:preferred_payment_method) { acleda_method_2 }

  describe '#execute' do
    it 'group by payment method type' do
      groups = described_class.new.execute(payment_methods: payment_methods, preferred_payment_method_id: preferred_payment_method.id)

      expect(groups.size).to eq 2
      expect(groups[0].name).to eq 'spree/gateway/acleda'
      expect(groups[1].name).to eq 'spree/gateway/payway_v2'

      # group acleda
      expect(groups[0].payment_methods.size).to eq 2
      expect(groups[0].payment_methods[0]).to eq acleda_method_2
      expect(groups[0].payment_methods[1]).to eq acleda_method_1

      # group aba
      expect(groups[1].payment_methods.size).to eq 2
      expect(groups[1].payment_methods[0]).to eq aba_method_2
      expect(groups[1].payment_methods[1]).to eq aba_method_1
    end
  end

  describe '#sort_payments' do
    it 'sort payment methods base on position when no preferred method provided' do
      sorted_payment_methods = described_class.new.sort_payments(
        payment_methods: payment_methods,
        preferred_payment_method_id: nil
      )

      expect(sorted_payment_methods.size).to eq 4
      expect(sorted_payment_methods[0]).to eq aba_method_2
      expect(sorted_payment_methods[1]).to eq acleda_method_1
      expect(sorted_payment_methods[2]).to eq acleda_method_2
      expect(sorted_payment_methods[3]).to eq aba_method_1
    end

    it 'sort payment methods base on position & preferred method' do
      sorted_payment_methods = described_class.new.sort_payments(
        payment_methods: payment_methods,
        preferred_payment_method_id: aba_method_1.id
      )

      expect(sorted_payment_methods.size).to eq 4
      expect(sorted_payment_methods[0]).to eq aba_method_1
      expect(sorted_payment_methods[1]).to eq aba_method_2
      expect(sorted_payment_methods[2]).to eq acleda_method_1
      expect(sorted_payment_methods[3]).to eq acleda_method_2
    end
  end
end
