require "spec_helper"

RSpec.describe SpreeCmCommissioner::OrderParamsChecker do
  let!(:order1) { create(:order, payment_state: 'paid', completed_at: '2019-12-31 13:30:30 UTC +00:00') }
  let!(:order2) { create(:order, payment_state: 'balance_due', created_at: '2019-12-31 13:30:30 UTC +00:00') }
  let(:paid_params) { { q: { completed_at_gteq: '2019-12-31', completed_at_lteq: '2019-12-31' } } }
  let(:balance_due_params) { { q: { created_at_gteq: '2019-12-31', created_at_lteq: '2019-12-31' } } }

  describe '.process_paid_params' do
    context 'when OrderParamsChecker is not used' do
      it 'does not find the order' do
        search = Spree::Order.ransack(completed_at_gteq: '2019-12-31', completed_at_lteq: '2019-12-31')
        orders = search.result.where(payment_state: 'paid')

        expect(orders.count).to eq(0)
      end
    end

    context 'when OrderParamsChecker is used' do
      let(:checked_params) { described_class.process_paid_params(paid_params) }

      it 'returns processed params' do
        expect(checked_params[:completed_at_lteq]).to eq('2019-12-31'.to_date.end_of_day)
      end

      it 'finds the order' do
        search = Spree::Order.ransack(completed_at_gteq: checked_params[:completed_at_gteq], completed_at_lteq: checked_params[:completed_at_lteq])
        orders = search.result.where(payment_state: 'paid')

        expect(orders.count).to eq(1)
        expect(orders.first).to eq(order1)
      end
    end
  end

  describe '.process_balance_due_params' do
    context 'when OrderParamsChecker is not used' do
      it 'does not find the order' do
        search = Spree::Order.ransack(created_at_gteq: '2019-12-31', created_at_lteq: '2019-12-31')
        orders = search.result.where(payment_state: 'balance_due')

        expect(orders.count).to eq(0)
      end
    end

    context 'when OrderParamsChecker is used' do
      let(:checked_params) { described_class.process_balance_due_params(balance_due_params) }

      it 'returns processed params' do
        expect(checked_params[:created_at_lteq]).to eq('2019-12-31'.to_date.end_of_day)
      end

      it 'finds the order' do
        search = Spree::Order.ransack(created_at_gteq: checked_params[:created_at_gteq], created_at_lteq: checked_params[:created_at_lteq])
        orders = search.result.where(payment_state: 'balance_due')

        expect(orders.count).to eq(1)
        expect(orders.first).to eq(order2)
      end
    end
  end
end
