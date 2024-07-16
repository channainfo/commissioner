require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionOrdersQuery do
  let(:customer) { create(:cm_customer) }
  let(:spree_current_user) { create(:user) }
  let(:admin_role) { create(:role, name: 'admin') }

  before do
    spree_current_user.spree_roles << admin_role
  end

  let(:subscription_jan2) { create(:cm_subscription, start_date: '2023-01-02'.to_date, customer: customer, price: 13.0, month: 1, due_date: 5, quantity: 1) }
  describe '#overdues' do
    it 'return 0 overdues when subscription not yet exceed due date' do
      subscription_jan2.orders.each {|o| o.payments.each{|p| p.void! }}

      query = described_class.new(
        current_date: '2023-01-04'.to_date,
        vendor_id: customer.vendor.id,
        from_date: '2000-01-01',
        to_date: '2100-01-01',
        spree_current_user: spree_current_user
      )

      expect(query.overdues.size).to eq 0
    end

    it 'return 0 overdues when due date == current date' do
      subscription_jan2.orders.each {|o| o.payments.each{|p| p.void! }}

      query = described_class.new(
        current_date: '2023-01-07'.to_date,
        vendor_id: customer.vendor.id,
        from_date: '2000-01-01',
        to_date: '2100-01-01',
        spree_current_user: spree_current_user
      )

      expect(query.overdues.size).to eq 0
    end

    it 'return 1 overdues when due date < current date' do
      subscription_jan2.orders.each {|o| o.payments.each{|p| p.void! }}

      query = described_class.new(
        current_date: '2023-01-08'.to_date,
        vendor_id: customer.vendor.id,
        from_date: '2000-01-01',
        to_date: '2100-01-01',
        spree_current_user: spree_current_user
      )

      expect(query.overdues.size).to eq 1
    end

    it "return 0 overdues when subscription's orders are paid" do
      subscription_jan2.orders.each {|o| o.payments.each{|p| p.capture! }}

      query = described_class.new(
        current_date: '2023-01-10'.to_date,
        vendor_id: customer.vendor.id,
        from_date: '2000-01-01',
        to_date: '2100-01-01',
        spree_current_user: spree_current_user
      )
    end
  end
end
