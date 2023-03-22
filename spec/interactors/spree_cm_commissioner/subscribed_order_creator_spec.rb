require 'spec_helper'

RSpec.describe SpreeCmCommissioner::SubscribedOrderCreator do
  describe ".call" do
    it "return 1 as subscription's order" do
      user = create(:user)
      option_type = create(:option_type, name: "month", attr_type: :integer)
      option_value = create(:option_value, name: "6 months", presentation: "6", option_type: option_type)

      vendor = create(:vendor)

      product = create(:base_product, option_types: [option_type], subscribable: true, vendor: vendor)
      variant = create(:base_variant, option_values: [option_value], price: 30, product: product)
      variant.stock_items.first.adjust_count_on_hand(10)

      customer = SpreeCmCommissioner::Customer.new(vendor: vendor, phone_number: "0962200288", user: user)

      SpreeCmCommissioner::Subscription.skip_callback(:create, :after, :create_order)
      subscription = SpreeCmCommissioner::Subscription.create(variant: variant, start_date: '2022-03-24', customer: customer)

      context = described_class.call(subscription: subscription)


      expect(context.order.subscription_id).to eq subscription.id
      expect(context.order.line_items.first.from_date).to eq subscription.start_date
      expect(context.order.line_items.first.to_date).to eq subscription.start_date + 6.months
      expect(context.order.total).to eq variant.price
      expect(context.order.user_id).to eq customer.user_id
      expect(context.order.id).to eq subscription.orders.first.id
    end
  end
end