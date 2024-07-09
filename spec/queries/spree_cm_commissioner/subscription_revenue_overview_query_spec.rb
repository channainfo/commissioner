require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionRevenueOverviewQuery do
  let(:vendor) { create(:vendor) }

  today = '2024-05-15'.to_date
  last_invoice_date = today - 1.month
  let!(:customer1) { create(:cm_customer, vendor: vendor, sequence_number: 01, last_invoice_date: last_invoice_date) }
  let!(:customer2) { create(:cm_customer, vendor: vendor, sequence_number: 02, last_invoice_date: last_invoice_date) }
  let!(:customer3) { create(:cm_customer, vendor: vendor, sequence_number: 03, last_invoice_date: last_invoice_date) }
  let(:spree_current_user) { create(:user) }
  let(:admin_role) { create(:role, name: 'admin') }

  before do
    spree_current_user.spree_roles << admin_role
  end

  describe '#reports' do
    before do
      create(:cm_subscription, start_date: (today - 1.month), customer: customer1, price: 13.0, due_date: 5, quantity: 1)
      create(:cm_subscription, start_date: (today - 1.month), customer: customer2, price: 25.0, due_date: 5, quantity: 1)
      create(:cm_subscription, start_date: (today - 1.month), customer: customer3, price: 32.0, due_date: 5, quantity: 1)
      SpreeCmCommissioner::SubscriptionsOrderCreator.call!(customer: customer1, today: today)
      SpreeCmCommissioner::SubscriptionsOrderCreator.call!(customer: customer2, today: today)
      SpreeCmCommissioner::SubscriptionsOrderCreator.call!(customer: customer3, today: today)
    end
    it 'only return totals in January' do
      SpreeCmCommissioner::Subscription.all.each do |subscription|
        subscription.orders.each {|o| o.payments.last.capture! }
      end

      # # only for may
      query = described_class.new(from_date: '2024-06-15', to_date: '2024-07-14', vendor_id: vendor.id, spree_current_user: spree_current_user)
      result = query.reports
      puts "Debug: Result - #{result}"
      expect(query.reports).to match_array [
        {:orders_count => 3, :state => "paid", :total => 13.0 + 25.0+ 32.0, :payment_total => 13.0 + 25.0+ 32.0}
      ]
    end

    it 'return totals group by payment state' do
      subscriptions = SpreeCmCommissioner::Subscription.all
      subscriptions[0].orders.each {|o| o.payments.last.pend! }
      subscriptions[1].orders.each {|o| o.payments.last.void! }
      subscriptions[2].orders.each {|o| o.payments.last.capture! }

      query = described_class.new(from_date: '2000-01-01', to_date: '2100-01-01', vendor_id: vendor.id, spree_current_user: spree_current_user)

      expect(query.reports).to match_array [
        {:orders_count => 1, :state => "paid", :total => 32.0, :payment_total => 32.0},
        {:orders_count => 1, :state => "balance_due", :total => 13.0, :payment_total => 0.0},
        {:orders_count => 1, :state => "failed", :total => 25.0, :payment_total => 0.0},
      ]
    end
  end

  # reference: subscription_orders_query_spec.rb
  describe '#reports_with_overdues' do
    before do
      create(:cm_subscription, start_date: today - 1.month, customer: customer1, price: 13.0, due_date: 5, quantity: 1)
      SpreeCmCommissioner::SubscriptionsOrderCreator.call(customer: customer1, today: today)
    end
    it 'return reports + overdue on feb' do
      SpreeCmCommissioner::Subscription.last.orders[0].payments.each{|p| p.pend!}

      query = described_class.new(
        current_date: '2024-09-07 ',
        vendor_id: vendor.id,
        from_date: '2000-01-01',
        to_date: '2100-01-01',
        spree_current_user: spree_current_user
      )

      expect(query.reports_with_overdues).to match_array [
        {:orders_count => 1, :state => "balance_due", :total => 13.0, :payment_total => 0.0},
        {:orders_count => 1, :state => "overdue", :total => 13.0, :payment_total => 0.0},
      ]
    end
  end
end
