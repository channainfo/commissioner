require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionsPrepaidOrderCreator do
  let(:vendor) { create(:vendor, code: 'VET', preferences: {penalty_rate: '3', six_months_discount: '1'}) }
  let(:customer) { create(:cm_customer, vendor: vendor) }
  let!(:subscription) {create(:cm_subscription, customer: customer, quantity: 5, start_date: Time.zone.now)}
  describe ".call" do

    context 'when creating a prepaid order' do
      before do
        total = customer.subscriptions.map(&:total_price).sum * 6
        credit =  create(:store_credit, user: customer.user, amount: total)
        described_class.call(customer: customer, store_credit: credit, duration: 6)
      end

      it 'creates a new order' do
        expect(Spree::Order.count).to eq(1)
        expect(Spree::Order.first.subscription_id).to eq(customer.subscriptions.first.id)
      end

      it 'creates an adjustment' do
        adjustments = customer.orders.last.adjustments
        expect(adjustments.count).to eq(1)
        expect(adjustments.first.amount).to eq(-subscription.total_price)
      end

      it 'creates a payment and captures it' do
        order = customer.orders.last
        expect(order.payments.count).to eq(1)
        expect(order.payment_state).to eq('paid')
      end

      it 'creates an invoice' do
        order = customer.orders.last
        expect(order.invoice).to be_present
        expect(order.invoice.order_id).to eq(order.id)
      end
    end
  end
end
