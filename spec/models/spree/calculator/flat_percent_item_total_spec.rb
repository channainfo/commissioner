require 'spec_helper'

RSpec.describe Spree::Calculator::FlatPercentItemTotal, type: :model do
  let(:calculator) { Spree::Calculator::FlatPercentItemTotal.new }
  let(:order) { create(:order) }

  before { allow(calculator).to receive_messages preferred_flat_percent: 10 }

  describe '#compute' do
    context 'without cap' do
      it 'rounds result correctly' do
        allow(order).to receive_messages amount: 31.08
        expect(calculator.compute(order)).to eq 3.11

        allow(order).to receive_messages amount: 31.00
        expect(calculator.compute(order)).to eq 3.10
      end

      it 'returns object.amount if computed amount is greater' do
        allow(order).to receive_messages amount: 30.00
        allow(calculator).to receive_messages preferred_flat_percent: 110

        expect(calculator.compute(order)).to eq 30.0
      end
    end

    context 'with cap' do
      before do
        calculator.update(cap: 10)
      end

      it 'returns cap if computed amount is greater' do
        allow(order).to receive_messages amount: 50.00
        allow(calculator).to receive_messages preferred_flat_percent: 50

        expect(calculator.compute(order)).to eq 10.00
      end

      it 'returns computed amount if cap is greater' do
        allow(order).to receive_messages amount: 15.00
        allow(calculator).to receive_messages preferred_flat_percent: 50

        expect(calculator.compute(order)).to eq 7.50
      end
    end
  end
end