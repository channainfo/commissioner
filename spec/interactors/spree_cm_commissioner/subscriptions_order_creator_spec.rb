require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionsOrderCreator do
  let(:vendor) { create(:vendor, code: 'VET', preferences: {penalty_rate: '3', six_months_discount: '1'}) }
  let(:customer) { create(:cm_customer, vendor: vendor) }

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
      context "when customer haven't paid the last order" do
        it 'add last invoice amount to the next invoice amount with 3% additional penalty' do
          create :cm_subscription, customer: customer, quantity: 1, start_date: today - 2.month
          order = create :order , user_id: customer.user.id, total: 30, item_total: 30, state: 'complete', completed_at: today - 1.month, payment_total: 20
          penalty_rate_amount = customer.orders.last.outstanding_balance * vendor.penalty_rate.to_f / 100
          customer.update!(last_invoice_date: today - 1.month)
          described_class.call(customer: customer, today: today)
          last_order = customer.orders.last
          expect(customer.orders.count).to eq 2
          expect(last_order.total).to eq last_order.item_total + order.outstanding_balance + penalty_rate_amount
        end
      end
      context "when customer have store credit" do
        before do
          create(:cm_subscription, customer: customer, quantity: 2, start_date: Time.zone.now.last_month)
          total = customer.subscriptions.map(&:total_price).sum * 6
          create(:store_credit, user: customer.user, amount: total)
        end
        it 'capture with store credit' do
          described_class.call(customer: customer, today: today)
          expect(customer.orders.last.payments.last.source_type).to eq('Spree::StoreCredit')
          expect(customer.orders.last.payments.last.state).to eq 'completed'
          expect(customer.user.store_credits.last.amount_used).to eq customer.orders.last.total
        end
      end
    end
  end
end
