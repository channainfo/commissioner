require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscriptionsOrderCronExecutor do
  let(:user) { create(:user) }

  let(:option_type_month) {create(:option_type, name: "month", attr_type: :integer)}
  let(:option_value_month){create(:option_value, presentation: "1 month", name: "1", option_type: option_type_month)}
  let(:option_type_day) {create(:option_type, name: "due-date", attr_type: :integer)}
  let(:option_value_day){create(:option_value, presentation: "5 Days", name: "5", option_type: option_type_day)}
  let(:option_type_payment) {create(:option_type, name: "payment-option", attr_type: :string)}
  let(:option_value_payment){create(:option_value, name: "post-paid", presentation: "post-paid", option_type: option_type_payment)}

  let(:vendor) { create(:vendor) }

  let(:product) { create(:base_product, option_types: [option_type_month, option_type_day, option_type_payment], subscribable: true, vendor: vendor) }
  let(:variant) { create(:base_variant, option_values: [option_value_month, option_value_day, option_value_payment], price: 30, product: product) }

  let(:customer1) { create(:cm_customer, vendor: vendor, phone_number: "0962200288") }
  let(:customer2) { create(:cm_customer, vendor: vendor, phone_number: "0972200288") }
  let(:customer3) { create(:cm_customer, vendor: vendor, phone_number: "0982200288") }

  before do
    # allow_any_instance_of(SpreeCmCommissioner::Subscription).to receive(:date_within_range).and_return(true)
    allow_any_instance_of(SpreeCmCommissioner::Subscription).to receive(:date_within_range).and_return(true)
    today = Time.zone.today
    today.day < 15 ?  three_month_ago = (today - 3.month).change(day: 14) : three_month_ago = (today - 3.month).change(day: 15)
    today.day < 15 ?  one_month_ago = (today - 1.month).change(day: 14) : one_month_ago = (today - 1.month).change(day: 15)
    SpreeCmCommissioner::Subscription.create!(variant: variant, start_date: three_month_ago, customer: customer1, quantity: 1)
    SpreeCmCommissioner::Subscription.create!(variant: variant, start_date: one_month_ago, customer: customer2, quantity: 1)
    SpreeCmCommissioner::Subscription.create!(variant: variant, start_date: today, customer: customer3, quantity: 1)

    customer1.update(last_invoice_date: three_month_ago)
    customer2.update(last_invoice_date: one_month_ago)
  end

  describe ".call" do
    it "creates invoices for all the missing months" do
      described_class.call()
      [customer1, customer2, customer3].each(&:reload)

      expect(customer1.orders.count).to eq 3
      expect(customer2.orders.count).to eq 1
      expect(customer3.orders.count).to eq 0
      expect(customer1.last_invoice_date).to eq (Time.zone.now).to_date
      expect(customer2.last_invoice_date).to eq (Time.zone.now).to_date
      expect(customer3.last_invoice_date).to eq nil
    end
  end
end
