require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PricingRate, type: :model do
  describe 'associations' do
    it { should belong_to(:pricing_rateable).inverse_of(:pricing_rates).required }
    it { should have_many(:applied_pricing_rates).class_name('SpreeCmCommissioner::AppliedPricingRate').dependent(:restrict_with_error) }
    it { should have_one(:default_price).class_name('Spree::Price') }
  end

  describe "callbacks" do
    it "saves default_price after save if it is present and changed or new" do
      subject = build(:cm_pricing_rate, price: 10)

      expect(subject.default_price.present?).to be true
      expect(subject.default_price.changed?).to be true
      expect(subject.default_price.new_record?).to be true

      expect(subject.default_price).to receive(:save).and_call_original

      subject.save

      expect(subject.default_price.amount).to eq 10
    end

    it "does not save default_price after save if it is not present" do
      RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

      subject = build(:cm_pricing_rate, default_price: nil)

      expect(subject.default_price.present?).to be false
      expect(subject.default_price).to_not receive(:save)

      subject.save

      RSpec::Mocks.configuration.allow_message_expectations_on_nil = false
    end

    it "does not save default_price after save if it is not changed or new record" do
      price = build(:price, amount: 10)
      subject = create(:cm_pricing_rate, default_price: price)

      expect(subject.default_price.changed?).to eq false
      expect(subject.default_price.new_record?).to eq false
      expect(subject.default_price).to_not receive(:save)

      subject.save
    end
  end

  describe "#find_or_build_default_price" do
    it "returns the default price if it exists" do
      default_price = Spree::Price.new(amount: 10)

      allow(subject).to receive(:default_price).and_return(default_price)
      expect(subject.find_or_build_default_price).to eq(default_price)
    end

    it "builds a new default price if it doesn't exist" do
      expect(subject.find_or_build_default_price).to be_a_new(Spree::Price)
    end
  end

  describe "#tax_category" do
    let(:tax_category) { create(:tax_category) }

    it "returns the tax category of the rateable object if available" do
      pricing_rateable = create(:variant, tax_category_id: tax_category.id)

      pricing_rate = SpreeCmCommissioner::PricingRate.new(pricing_rateable: pricing_rateable)

      expect(pricing_rate.tax_category).to eq tax_category
    end

    it "returns nil if the rateable object does not have a tax category" do
      pricing_rateable = create(:variant, product: create(:product, tax_category_id: nil))

      pricing_rate = SpreeCmCommissioner::PricingRate.new(pricing_rateable: pricing_rateable)

      expect(pricing_rate.tax_category).to be_nil
    end
  end
end
