require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionOrdersQuery do
  let(:customer) { create(:cm_customer) }

  let(:subscription_jan2) { create(:cm_subscription, start_date: '2023-01-02'.to_date, customer: customer, price: 13.0, month: 1) }
  let(:subscription_jan4) { create(:cm_subscription, start_date: '2023-01-04'.to_date, customer: customer, price: 25.0, month: 1) }
  let(:subscription_feb4) { create(:cm_subscription, start_date: '2023-02-04'.to_date, customer: customer, price: 32.0, month: 1) }

  describe '#overdues' do
    it 'return unpaid orders before april of subscriptions with single order' do
      subscription_jan2.orders.each {|o| o.payments.each{|p| p.void! }}
      subscription_jan4.orders.each {|o| o.payments.each{|p| p.pend! }}
      subscription_feb4.orders.each {|o| o.payments.each{|p| p.capture! }}

      query = described_class.new(
        current_date: '2023-04-21'.to_date,
        vendor_id: customer.vendor.id,
        from_date: '2000-01-01',
        to_date: '2100-01-01',
      )

      overdues_orders = query.overdues

      expect(overdues_orders.size).to eq 2
      expect(overdues_orders[0].total).to eq 13.0
      expect(overdues_orders[1].total).to eq 25.0
    end

    it 'return unpaid orders before april of subscriptions with multi orders' do
      subscription = subscription_jan2
      subscription.create_order # billing for february
      subscription.create_order # billing for march

      subscription.orders[0].payments.each{|p| p.capture!} # january
      subscription.orders[1].payments.each{|p| p.void!} # february
      subscription.orders[2].payments.each{|p| p.void!} # march

      query = described_class.new(
        current_date: '2023-04-21'.to_date,
        vendor_id: customer.vendor.id,
        from_date: '2000-01-01',
        to_date: '2100-01-01',
      )

      overdues_orders = query.overdues

      expect(subscription.orders.size).to eq 3

      expect(overdues_orders.size).to eq 2
      expect(overdues_orders[0].total).to eq 13.0
      expect(overdues_orders[1].total).to eq 13.0

      expect(overdues_orders[0].line_items[0].from_date).to eq subscription.start_date + 1.month
      expect(overdues_orders[1].line_items[0].from_date).to eq subscription.start_date + 2.month
    end
  end
end