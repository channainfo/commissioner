require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscribedOrderCreator do
  let(:customer) { create(:cm_customer) }
  let(:vendor) {create(:vendor)}

  let(:option_type) {create(:option_type, name: "due-date", attr_type: :integer)}
  let(:option_value){create(:option_value, name: "5 Days", presentation: "5", option_type: option_type)}

  let(:product) { create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor)}
  let(:variant) { create(:base_variant, option_values: [option_value], price: 30, product: product, permanent_stock: 1 )}

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
      expect(context.order.line_items[0].due_date).to eq context.order.line_items[0].from_date + 5.days
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