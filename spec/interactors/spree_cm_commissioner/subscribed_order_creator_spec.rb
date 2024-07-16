require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscribedOrderCreator do
  let(:customer) { create(:cm_customer) }
  let(:vendor) {create(:vendor)}

  let(:option_type) {create(:option_type, name: "due-date", attr_type: :integer)}
  let(:option_value){create(:option_value, name: "5", presentation: "5 Days", option_type: option_type)}

  let(:product1) { create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor)}
  let(:product2) { create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor)}
  let(:variant1) { create(:cm_base_variant, option_values: [option_value], price: 30, product: product1, total_inventory: 1 )}
  let(:variant2) { create(:cm_base_variant, option_values: [option_value], price: 30, product: product2, total_inventory: 1 )}

  let(:stock_location) { create(:stock_location, vendor: vendor) }
  let(:stock_item1) { create(:stock_item, stock_location: stock_location, variant: variant1, count_on_hand: 10) }
  let(:stock_item2) { create(:stock_item, stock_location: stock_location, variant: variant2, count_on_hand: 10) }

  describe ".call" do
    context "when customer has no prior subscription" do
      it "return a newly created order" do
        subscription = create(:cm_subscription, customer: customer, quantity: 2, start_date: '2023-01-02'.to_date)

        context = described_class.call(subscription: subscription)

        expect(context.order).to be_a(Spree::Order)
        expect(context.order.customer).to eq customer
        expect(context.order.line_items.size).to eq 1
        expect(context.order.line_items[0].variant).to eq subscription.variant
        expect(context.order.line_items[0].quantity).to eq 2
        expect(customer.last_invoice_date).to eq Time.zone.now.to_date
      end
    end

    context "when subscriptions is later than this month" do
      it "do not create any order"do
        subscription1 = create(:cm_subscription, customer: customer, quantity: 2, start_date: '2024-12-02'.to_date)
        subscription2 = create(:cm_subscription, customer: customer, quantity: 2, start_date: '2025-01-02'.to_date)
        expect(customer.orders.count).to eq 0
        expect(customer.subscriptions.count).to eq 2
        expect(customer.subscriptions).to include(subscription1)
        expect(customer.subscriptions).to include(subscription2)
      end
      it "doesn't set last_invoice_date" do
        expect(customer.last_invoice_date).to eq nil
      end
    end

    context "when customer has prior subscription" do
      let(:subscription1) { create(:cm_subscription, customer: customer, quantity: 2, start_date: '2023-01-02'.to_date) }
      let(:order1) { described_class.call(subscription: subscription1).order}

      it "return the first order when customer has prior subscription" do
        subscription2 = create(:cm_subscription, customer: customer, quantity: 2, start_date: '2023-01-02'.to_date)

        context = described_class.call(subscription: subscription2)

        expect(context.order).to eq(order1)
      end
    end

    it 'created a default payment' do
      subscription = create(:cm_subscription, customer: customer, quantity: 1)

      context = described_class.call(subscription: subscription)

      expect(context.order.payments.size).to eq 2
      expect(context.order.payments[-1].amount).to eq context.order.order_total_after_store_credit
      expect(context.order.payments[-1].state).to eq 'checkout'
    end

    it 'update invoice everytime a new service is subscribed' do
      subscription1 = create(:cm_subscription, customer: customer, start_date: '2023-01-02'.to_date, quantity: 1)
      context1 = described_class.call(subscription: subscription1)

      expect(context1.order.line_items.size).to eq 1

      subscription2 = create(:cm_subscription, customer: customer, quantity: 1)
      context2 = described_class.call(subscription: subscription2)

      expect(context1.order.line_items.size).to eq 2
      expect(context1.order).to eq context2.order
      expect(context1.order.invoice).to eq context2.order.invoice
    end

    it 'create an order with the correct due date with pre-paid option' do
      subscription = create(:cm_subscription, customer: customer, start_date: '2023-01-02'.to_date, price: 13.0, month: 1, quantity: 1)

      context = described_class.call(subscription: subscription)

      expect(context.order.line_items.last.due_date).to eq '2023-01-07'.to_date
    end

    it 'create an order with the correct due date with post-paid option' do
      subscription = create(:cm_subscription, customer: customer, start_date: '2023-01-02'.to_date, price: 13.0, month: 1, payment_option:'post-paid', quantity: 1)

      context = described_class.call(subscription: subscription)

      expect(context.order.line_items.last.due_date).to eq '2023-02-07'.to_date
    end
  end
end
