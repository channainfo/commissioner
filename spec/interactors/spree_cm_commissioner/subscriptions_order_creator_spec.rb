require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionsOrderCreator do
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

  let(:subscription1) { create(:cm_subscription, customer: customer, quantity: 2, start_date: '2023-01-02'.to_date) }
  let(:subscription2) { create(:cm_subscription, customer: customer, quantity: 2, start_date: '2023-01-02'.to_date) }
  describe ".call" do
    context "when customer has no subscription" do
      it "does nothing" do
        described_class.call(customer: customer)
        expect(customer.orders).to be_empty
      end
    end
    context "when customer has subscription" do
      it "creates a new order" do
        expect(customer.subscriptions).to include(subscription2)
        expect(customer.subscriptions).to include(subscription1)
        expect(customer.orders.count).to eq 1
        described_class.call(customer: customer)
        expect(customer.orders.count).to eq 2
      end
    end
    context "when customer already have invoice for this month" do
      it 'throw error' do
        expect(customer.subscriptions).to include(subscription2)
        expect(customer.subscriptions).to include(subscription1)
        described_class.call(customer: customer)
        expect(customer.orders.count).to eq 2
        result = described_class.call(customer: customer)
        expect(customer.orders.count).to eq 2
        expect(result.error).to eq 'Invoice for this month is already existed'
      end
    end
  end
end
