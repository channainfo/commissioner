require 'spec_helper'

RSpec.describe Spree::Billing::ReportsController, type: :controller do
  let!(:customer) { create(:cm_customer) }
  let(:spree_current_user) { create(:user) }
  let(:admin_role) { create(:role, name: 'admin') }

  before do
    spree_current_user.spree_roles << admin_role
  end

  before(:each) do
    allow_any_instance_of(SpreeCmCommissioner::Subscription).to receive(:date_within_range).and_return(true)
    create(:cm_subscription, start_date: '2024-05-15'.to_date, customer: customer, price: 13.0, due_date: 5, quantity: 1)
    create(:cm_subscription, start_date: '2024-05-16'.to_date, customer: customer, price: 25.0, due_date: 5, quantity: 1)
    create(:cm_subscription, start_date: '2024-05-17'.to_date, customer: customer, price: 32.0, due_date: 5, quantity: 1)
    SpreeCmCommissioner::SubscriptionsOrderCreator.call(customer: customer)
  end

  describe 'overdue_report' do
    before do
      SpreeCmCommissioner::Subscription.all.each do |subscription|
        subscription.orders.each {|o| o.payments.last.pend! }
      end
    end

    # one order with 3 line items
    it 'returns only 1 order with overdue payment state' do
      search = Spree::Order.subscription.joins(:line_items).where.not(payment_state: %w[paid failed])
                                                           .where('spree_line_items.due_date < ?', Time.zone.today)
                                                           .select('DISTINCT ON (spree_orders.id) spree_orders.*, spree_line_items.*')

      expect(search.size).to eq 1
    end

    # 3 orders with 3 line items each (same order number)
    it 'returns duplicate orders with overdue payment state' do
      search = Spree::Order.subscription.joins(:line_items).where.not(payment_state: %w[paid failed])
                                                           .where('spree_line_items.due_date < ?', Time.zone.today)

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
                    .select('DISTINCT ON (spree_orders.id) spree_orders.*, spree_line_items.*')

      expect(search.size).to eq 1
    end

    # 3 orders with 3 line items each (same order number)
    it 'returns duplicate orders with failed payment state' do
      search = Spree::Order.subscription.joins(:line_items)
                    .where(payment_state: 'failed')

      expect(search.size).to eq 3
    end
  end
end

