require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionRevenueOverviewQuery do
  let(:customer) { create(:cm_customer) }

  describe '#reports' do
    let(:subscription_jan2) { create(:cm_subscription, start_date: '2023-01-02'.to_date, customer: customer, price: 13.0) }
    let(:subscription_jan4) { create(:cm_subscription, start_date: '2023-01-04'.to_date, customer: customer, price: 25.0) }
    let(:subscription_feb4) { create(:cm_subscription, start_date: '2023-02-04'.to_date, customer: customer, price: 32.0) }

    it 'only return totals in January' do
      subscription_jan2.orders.each {|o| o.payments.each{|p| p.capture! }}
      subscription_jan4.orders.each {|o| o.payments.each{|p| p.capture! }}
      subscription_feb4.orders.each {|o| o.payments.each{|p| p.capture! }}

      # only for january
      query = described_class.new(from_date: '2023-01-01', to_date: '2023-01-31', vendor_id: customer.vendor.id)

      expect(query.reports).to match_array [
        {:orders_count => 2, :state => "paid", :total => 13.0 + 25.0, :payment_total => 13.0 + 25.0}
      ]
    end

    it 'return totals group by payment state' do
      subscription_jan2.orders.each {|o| o.payments.each{|p| p.pend! }}
      subscription_jan4.orders.each {|o| o.payments.each{|p| p.void! }}
      subscription_feb4.orders.each {|o| o.payments.each{|p| p.capture! }}

      query = described_class.new(from_date: '2000-01-01', to_date: '2100-01-01', vendor_id: customer.vendor.id)

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
      subscription = create(:cm_subscription, start_date: '2023-01-02'.to_date, customer: customer, price: 13.0, month: 1)
      subscription.create_order
      subscription.create_order

      subscription.orders[0].payments.each{|p| p.capture!} # january
      subscription.orders[1].payments.each{|p| p.void!} # february
      subscription.orders[2].payments.each{|p| p.void!} # march

      query = described_class.new(
        current_date: '2023-03-21', # april
        vendor_id: customer.vendor.id,
        from_date: '2000-01-01',
        to_date: '2100-01-01',
      )

      expect(query.reports_with_overdues).to match_array [
        {:orders_count => 1, :state => "paid", :total => 13.0, :payment_total => 13.0},
        {:orders_count => 1, :state => "overdue", :total => 13.0, :payment_total => 0.0},
        {:orders_count => 2, :state => "failed", :total => 13.0 * 2, :payment_total => 0.0},
      ]

      expect(subscription.orders[0].line_items[0].from_date).to eq subscription.start_date
      expect(subscription.orders[1].line_items[0].from_date).to eq subscription.start_date + 1.month
      expect(subscription.orders[2].line_items[0].from_date).to eq subscription.start_date + 2.months
    end
  end
end