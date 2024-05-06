require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionsOrderCronExecutor do
  let(:user) { create(:user) }

  let(:option_type_month) {create(:option_type, name: "month", attr_type: :integer)}
  let(:option_value_month){create(:option_value, name: "1 month", presentation: "1", option_type: option_type_month)}
  let(:option_type_day) {create(:option_type, name: "due-date", attr_type: :integer)}
  let(:option_value_day){create(:option_value, name: "5 Days", presentation: "5", option_type: option_type_day)}
  let(:option_type_payment) {create(:option_type, name: "payment-option", attr_type: :string)}
  let(:option_value_payment){create(:option_value, name: "post-paid", presentation: "post-paid", option_type: option_type_payment)}


  let(:vendor) {create(:vendor)}

  let(:product) { create(:base_product, option_types: [option_type_month,option_type_day,option_type_payment], subscribable: true, vendor: vendor)}
  let(:variant) { create(:base_variant, option_values: [option_value_month,option_value_day,option_value_payment], price: 30, product: product)}

  before(:each) do
    variant.stock_items.first.adjust_count_on_hand(10)

    customer = create(:cm_customer, vendor: vendor, phone_number: "0962200288", user: user)
    vendor.reload
    customer2 = create(:cm_customer, vendor: vendor, phone_number: "0972200288", user: user)
    vendor.reload
    customer3 = create(:cm_customer, vendor: vendor, phone_number: "0982200288", user: user)
    vendor.reload

    subscription1 = SpreeCmCommissioner::Subscription.create!(variant: variant, start_date: '2021-01-01', customer: customer)
    subscription2 = SpreeCmCommissioner::Subscription.create!(variant: variant, start_date: '2021-02-01', customer: customer2)
    subscription3 = SpreeCmCommissioner::Subscription.create!(variant: variant, start_date: '2021-03-01', customer: customer3)
  end

  describe ".call" do
    it "renews all expired subscription by 1 month" do
      instance = described_class.new(current: Date.parse('2021-03-01'))
      instance.call
      # renew orders should be 2 as 2 subscriptions are expired
      expect(instance.remaining_subscriptions.size).to eq 2
    end
  end

  describe "#partition_orders" do
    it "return all subscription orders" do
      instance = described_class.new(current: Date.parse('2021-03-01'))
      expect(instance.partition_orders.size).to eq 3
    end
  end

  describe "#last_orders" do
    it "return all subscription last order" do
      instance = described_class.new(current: Date.parse('2021-03-01'))
      expect(instance.last_orders.size).to eq 3
    end
  end

  describe "#remaining_subscriptions" do
    it "return all the expired subscriptions" do
      instance = described_class.new(current: Date.parse('2021-03-01'))
      expect(instance.remaining_subscriptions.first.customer.phone_number).to eq "0962200288"
    end
  end
end