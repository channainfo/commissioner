require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionsOrderCronExecutor do
  let(:user) { create(:user) }

  let(:option_type) {create(:option_type, name: "month", attr_type: :integer)}
  let(:option_value){create(:option_value, name: "1 month", presentation: "1", option_type: option_type)}

  let(:vendor) {create(:vendor)}

  let(:product) { create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor)}
  let(:variant) { create(:base_variant, option_values: [option_value], price: 30, product: product)}

  before(:each) do
    variant.stock_items.first.adjust_count_on_hand(10)

    customer = SpreeCmCommissioner::Customer.new(vendor: vendor, phone_number: "0962200288", user: user)
    customer2 = SpreeCmCommissioner::Customer.new(vendor: vendor, phone_number: "0972200288", user: user)
    customer3 = SpreeCmCommissioner::Customer.new(vendor: vendor, phone_number: "0982200288", user: user)

    subscription1 = SpreeCmCommissioner::Subscription.create(variant: variant, start_date: '2021-01-01', customer: customer)
    subscription2 = SpreeCmCommissioner::Subscription.create(variant: variant, start_date: '2021-02-01', customer: customer2)
    subscription3 = SpreeCmCommissioner::Subscription.create(variant: variant, start_date: '2021-03-01', customer: customer3)
  end

  describe ".call" do
    it "renews all expired subscription by 1 month" do
      instance = described_class.new(current: Date.parse('2021-03-01'))
      instance.call
      # january still has 1 order left
      expect(instance.remaining_subscriptions.size).to eq 1
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