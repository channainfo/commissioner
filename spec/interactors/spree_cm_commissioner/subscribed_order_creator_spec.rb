require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscribedOrderCreator do
  let(:customer) { create(:cm_customer) }

  describe ".call" do
    it "return a newly created order" do
      subscription = create(:cm_subscription, start_date: '2023-01-02'.to_date, customer: customer, price: 13.0, month: 1)
      context = described_class.call(subscription: subscription)

      expect(subscription.orders.size).to eq 2
      expect(context.order.subscription_id).to eq subscription.id
      expect(context.order.line_items[0].from_date).to eq subscription.start_date + 1.months
      expect(context.order.line_items[0].to_date).to eq subscription.start_date + 2.months
      expect(context.order.total).to eq subscription.variant.price
      expect(context.order.user_id).to eq customer.user_id
    end

    it 'created a default payment' do
      subscription = create(:cm_subscription, customer: customer)

      context = described_class.call(subscription: subscription)

      expect(context.order.payments.size).to eq 1
      expect(context.order.payments[0].amount).to eq context.order.order_total_after_store_credit
      expect(context.order.payments[0].state).to eq 'checkout'
    end
  end
end