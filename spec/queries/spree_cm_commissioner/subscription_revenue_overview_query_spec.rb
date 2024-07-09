require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionRevenueOverviewQuery do
  let(:vendor) { create(:vendor) }
  let(:customer1) { create(:cm_customer, vendor: vendor, sequence_number: 01) }
  let(:customer2) { create(:cm_customer, vendor: vendor, sequence_number: 02) }
  let(:customer3) { create(:cm_customer, vendor: vendor, sequence_number: 03) }
  let(:spree_current_user) { create(:user) }
  let(:admin_role) { create(:role, name: 'admin') }

  before do
    spree_current_user.spree_roles << admin_role
  end

  describe '#reports' do
    let(:subscription_jan2) { create(:cm_subscription, start_date: '2023-01-02'.to_date, customer: customer1, price: 13.0, due_date: 5) }
    let(:subscription_jan4) { create(:cm_subscription, start_date: '2023-01-04'.to_date, customer: customer2, price: 25.0, due_date: 5) }
    let(:subscription_feb4) { create(:cm_subscription, start_date: '2023-02-04'.to_date, customer: customer3, price: 32.0, due_date: 5) }

    it 'only return totals in January' do
      subscription_jan2.orders.each {|o| o.payments.last.capture! }
      subscription_jan4.orders.each {|o| o.payments.last.capture! }
      subscription_feb4.orders.each {|o| o.payments.last.capture! }

      # only for january
      query = described_class.new(from_date: '2023-01-01', to_date: '2023-01-31', vendor_id: vendor.id, spree_current_user: spree_current_user)
      result = query.reports
      puts "Debug: Result - #{result}"

      expect(query.reports).to match_array [
        {:orders_count => 2, :state => "paid", :total => 13.0 + 25.0, :payment_total => 13.0 + 25.0}
      ]
    end

    it 'return totals group by payment state' do
      subscription_jan2.orders.each {|o| o.payments.last.pend! }
      subscription_jan4.orders.each {|o| o.payments.last.void! }
      subscription_feb4.orders.each {|o| o.payments.last.capture! }

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
    it 'return reports + overdue on feb' do
      subscription = create(:cm_subscription, start_date: '2023-01-02'.to_date, customer: customer1, price: 13.0, month: 1, due_date: 5)
      subscription.orders[0].payments.each{|p| p.pend!}

      query = described_class.new(
        current_date: '2023-01-28',
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