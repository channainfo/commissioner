require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Subscription, type: :model do
  describe "#months_count" do
    it "return 6 as month count" do
      option_type = create(:option_type, name: "month", attr_type: :integer)
      option_value = create(:option_value, presentation: "6 Months", name: "6", option_type: option_type)

      product = create(:base_product, option_types: [option_type], subscribable: true)
      product.variants << create(:base_variant, option_values: [option_value], price: 30)

      subscription = described_class.new(variant: product.variants.first, start_date: '2022-03-24')
      expect(subscription.months_count).to eq 6
    end
  end
end