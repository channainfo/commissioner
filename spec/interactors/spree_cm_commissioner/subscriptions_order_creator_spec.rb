require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionsOrderCreator do
  let(:customer) { create(:cm_customer) }
  let(:vendor) { create(:vendor, code: 'VET') }

  let(:option_type) { create(:option_type, name: "due-date", attr_type: :integer) }
  let(:option_value) { create(:option_value, name: "15", presentation: "5 Days", option_type: option_type) }

  let(:product1) { create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor) }
  let(:product2) { create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor) }
  let(:variant1) { create(:cm_base_variant, option_values: [option_value], price: 30, product: product1, total_inventory: 1) }
  let(:variant2) { create(:cm_base_variant, option_values: [option_value], price: 30, product: product2, total_inventory: 1) }

  let(:stock_location) { create(:stock_location, vendor: vendor) }
  let(:stock_item1) { create(:stock_item, stock_location: stock_location, variant: variant1, count_on_hand: 10) }
  let(:stock_item2) { create(:stock_item, stock_location: stock_location, variant: variant2, count_on_hand: 10) }
  today = Time.zone.today
  describe ".call" do
    context "when customer has no subscription" do
      it "does nothing" do
        described_class.call(customer: customer, today: today)
        expect(customer.orders).to be_empty
        expect(customer.last_invoice_date).to eq nil
      end
    end

    context "when customer has subscriptions" do
      context "when there are 3 missed months" do
        before do
          travel_to 3.months.ago do
            today_3_month_ago = Time.zone.today
            start_date = today_3_month_ago.day < 15 ? today_3_month_ago.change(day: 15) - 1.month : today_3_month_ago.change(day: 15)
            create(:cm_subscription, customer: customer, quantity: 2, start_date: start_date)
            create(:cm_subscription, customer: customer, quantity: 2, start_date: start_date)
            customer.update!(last_invoice_date: start_date)
          end
        end

        it "creates invoices for all the missing months" do
          described_class.call(customer: customer, today: today)
          expect(customer.orders.count).to eq 3
        end

        it "updates the last_invoice_date of the customer" do
          described_class.call(customer: customer, today: today)
          expect(customer.last_invoice_date).to eq today
        end
      end

      context "when there are 3 missed months and also time for future subscription to start" do
        before do
          travel_to 3.months.ago do
            today_3_month_ago = Time.zone.today
            three_months_ago = today_3_month_ago.day < 15 ? (today_3_month_ago - 1.month).change(day: 15) :  today_3_month_ago.change(day: 15)
            create(:cm_subscription, customer: customer, quantity: 2, start_date: three_months_ago)
            create(:cm_subscription, customer: customer, quantity: 2, start_date: three_months_ago)
            create(:cm_subscription, customer: customer, quantity: 2, start_date:  three_months_ago)
            customer.last_invoice_date =  three_months_ago
          end
          start_date = today.day < 15 ? today.change(day: 15) - 2.month : today.change(day: 15) - 1.month
          customer.subscriptions.last.update(start_date: start_date)
        end

        it "creates invoices for all missing months" do
          described_class.call(customer: customer, today: today)
          expect(customer.orders.count).to eq 3
        end

        it "does not include the future subscription in the first two missing months" do
          described_class.call(customer: customer, today: today)
          expect(customer.orders[0].line_items.count).to eq 2
          expect(customer.orders[1].line_items.count).to eq 2
          expect(customer.orders[2].line_items.count).to eq 3
        end
      end

      context "when there are no missed months" do
        before do
          travel_to 1.month.ago do
            today_1_month_ago = Time.zone.today
            start_date = today_1_month_ago.day < 15 ? today_1_month_ago.change(day: 15) - 1.month : today_1_month_ago.change(day: 15)
            create(:cm_subscription, customer: customer, quantity: 2, start_date: start_date)
          end
          customer.update!(last_invoice_date: today)
        end

        it "doesn't create any orders" do
          described_class.call(customer: customer, today: today)
          expect(customer.orders.count).to eq 0
        end

        it "doesn't update the last_invoice_date of the customer" do
          described_class.call(customer: customer, today: today)
          expect(customer.last_invoice_date).to eq today
        end
      end

      context "when there are no missed months but it's time for future subscription to start" do
        before do
          travel_to 1.month.ago do
            today_1_month_ago = Time.zone.today
            start_date = today_1_month_ago.day < 15 ? today_1_month_ago.change(day: 15) - 1.month : today_1_month_ago.change(day: 15)
            create(:cm_subscription, customer: customer, quantity: 2, start_date: start_date)
          end
        end

        it "creates a new order for the future subscription" do
            expect(customer.orders.count).to eq 0
            expect(customer.last_invoice_date).to eq nil
            described_class.call(customer: customer, today: today)
            expect(customer.orders.count).to eq 1
            expect(customer.last_invoice_date).to eq today
        end
      end
    end
  end
end
