require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionsOrderCreator do
  let(:customer) { create(:cm_customer) }
  let(:vendor) {create(:vendor)}

  let(:option_type) {create(:option_type, name: "due-date", attr_type: :integer)}
  let(:option_value){create(:option_value, name: "15", presentation: "5 Days", option_type: option_type)}

  let(:product1) { create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor)}
  let(:product2) { create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor)}
  let(:variant1) { create(:cm_base_variant, option_values: [option_value], price: 30, product: product1, total_inventory: 1 )}
  let(:variant2) { create(:cm_base_variant, option_values: [option_value], price: 30, product: product2, total_inventory: 1 )}

  let(:stock_location) { create(:stock_location, vendor: vendor) }
  let(:stock_item1) { create(:stock_item, stock_location: stock_location, variant: variant1, count_on_hand: 10) }
  let(:stock_item2) { create(:stock_item, stock_location: stock_location, variant: variant2, count_on_hand: 10) }

  describe ".call" do
    context "when customer has no subscription" do
      it "does nothing" do
        described_class.call(customer: customer)
        expect(customer.orders).to be_empty
        expect(customer.last_invoice_date).to eq nil
      end
    end
    context "when customer has subscriptions" do
      context "when there are 3 missed months" do
        before do
          allow_any_instance_of(SpreeCmCommissioner::Subscription).to receive(:date_within_range).and_return(true)
          today = Time.zone.today
          today.day < 15 ?  three_month_ago = (today - 3.month).change(day: 14) : three_month_ago = (today - 3.month).change(day: 15)
          #March 15th 2024, 15th April 2024, 15th May 2024, 15th June
          create(:cm_subscription, customer: customer, quantity: 2, start_date: three_month_ago,)
          create(:cm_subscription, customer: customer, quantity: 2, start_date: three_month_ago)
          customer.last_invoice_date = three_month_ago
        end

        it "create invoices for all the missing months" do
          described_class.call(customer: customer)
          expect(customer.orders.count).to eq 3
        end
        it "update the last_invoice_date of the customer" do
          described_class.call(customer: customer)
          expect(customer.last_invoice_date).to eq Time.zone.now.to_date
        end
      end
      context "when there are 3 missed months and also time for future subscription to start" do
        before do
          allow_any_instance_of(SpreeCmCommissioner::Subscription).to receive(:date_within_range).and_return(true)
          #14th April, 14th May, 14th June
          today = Time.zone.today
          if today.day < 15
            start_date = (today - 1.month).change(day: 14)
            three_month_ago = (today - 3.month).change(day: 14)
          else
            #15th April 2024, 15th May 2024, 15th June 2024
            start_date = today.change(day: 14)
            three_month_ago = (today - 3.month).change(day: 15)
          end
          create(:cm_subscription, customer: customer, quantity: 2, start_date: three_month_ago)
          create(:cm_subscription, customer: customer, quantity: 2, start_date: three_month_ago)
          create(:cm_subscription, customer: customer, quantity: 2, start_date: three_month_ago)
          customer.subscriptions.last.update(start_date: start_date)
          customer.last_invoice_date =  three_month_ago
        end
        it "create invoices for all missing months " do
          described_class.call(customer: customer)
          expect(customer.orders.count).to eq 3
        end
        it "does not include the future subscription in the first two missing months" do
          described_class.call(customer: customer)
          expect(customer.orders[0].line_items.count).to eq 2
          expect(customer.orders[1].line_items.count).to eq 2
          expect(customer.orders[2].line_items.count).to eq 3
        end
      end
      context "When there are no missed month" do
        before do
          allow_any_instance_of(SpreeCmCommissioner::Subscription).to receive(:date_within_range).and_return(true)
          today = Time.zone.today
          today.day < 15 ? start_date = (today - 1.month).change(day: 15) : start_date = today.change(day: 15)
          create(:cm_subscription, customer: customer, quantity: 2, start_date: start_date )
        end
        it "doesn't create any orders" do
          described_class.call(customer: customer)
          expect(customer.orders.count).to eq 0
        end
        it "doesn't update the last_invoice_date of the customer" do
          described_class.call(customer: customer)
          expect(customer.last_invoice_date).to eq nil
        end
      end
      context "When there are no missed month but it's time for future subscription to start" do
        before do
          allow_any_instance_of(SpreeCmCommissioner::Subscription).to receive(:date_within_range).and_return(true)
          today = Time.zone.today
          today.day < 15 ? start_date = (today - 1.month).change(day: 14) : start_date = today.change(day: 14)
          subscription = create(:cm_subscription, customer: customer, quantity: 2, start_date: Time.zone.now + 2.month)
          subscription.update(start_date: start_date)
        end
        it " create a new order for the future subscription " do
          expect(customer.orders.count).to eq 0
          expect(customer.last_invoice_date).to eq nil
          described_class.call(customer: customer)
          expect(customer.orders.count).to eq 1
          expect(customer.last_invoice_date).to eq Time.zone.now.to_date
        end
      end
    end
  end
end
