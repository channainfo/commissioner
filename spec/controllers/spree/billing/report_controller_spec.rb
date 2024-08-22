require 'spec_helper'

RSpec.describe Spree::Billing::ReportsController, type: :controller do
  today = '2021-08-15'.to_date
  let!(:customer) { create(:cm_customer, last_invoice_date: today - 2.month) }
  let(:spree_current_user) { create(:user) }
  let(:admin_role) { create(:role, name: 'admin') }

  before do
    spree_current_user.spree_roles << admin_role
  end

  before(:each) do
    start_date = today - 2.month
    create(:cm_subscription, start_date: start_date, customer: customer, price: 13.0, due_date: 5, quantity: 1)
    create(:cm_subscription, start_date: start_date, customer: customer, price: 25.0, due_date: 5, quantity: 1)
    create(:cm_subscription, start_date: start_date, customer: customer, price: 32.0, due_date: 5, quantity: 1)
    SpreeCmCommissioner::SubscriptionsOrderCreator.call!(customer: customer, today: today)
  end

  describe 'overdue_report' do
    before do
      SpreeCmCommissioner::Subscription.all.each do |subscription|
        subscription.orders.each {|o| o.payments.last.pend! }
      end
    end

    # one order with 3 line items
    it 'returns only 1 order with overdue payment state' do
      search = Spree::Order.subscription.joins(:line_items).where(payment_state: :balance_due)
                                                           .where('spree_line_items.due_date < ?', today)

      result = search.includes(:line_items)

      # 1 overdue and 1 balance_due orders in 2 months
      expect(result.size).to eq 1
    end

    # 3 orders with 3 line items each (same order number)
    it 'returns duplicate orders with overdue payment state' do
      search = Spree::Order.subscription.joins(:line_items).where(payment_state: :balance_due)
                                                           .where('spree_line_items.due_date < ?', today)

      # 3 overdue and 3 balance_due orders in 2 months
      expect(search.size).to eq 3
    end
  end

  describe 'failed_report' do
    before do
      SpreeCmCommissioner::Subscription.all.each do |subscription|
        subscription.orders.each {|o| o.payments.last.void! }
      end
    end

    # one order with 3 line items
    it 'returns only 1 order with failed payment state' do
      search = Spree::Order.subscription.joins(:line_items)
                    .where(payment_state: 'failed')

      result = search.includes(:line_items)

      # 2 orders in 2 months
      expect(result.size).to eq 2
    end

    # 3 orders with 3 line items each (same order number)
    it 'returns duplicate orders with failed payment state' do
      search = Spree::Order.subscription.joins(:line_items)
                    .where(payment_state: 'failed')


      # 6 orders in 2 months
      expect(search.size).to eq 6
    end
  end
end
