require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorPriceRulesActivator do
  context 'match any date' do
    let!(:vendor) { create(:active_vendor, min_price: 20.0, max_price: 100.0) }

    let(:calculator) { Spree::Calculator::FlatRate.new(preferred_amount: 10.0) } # -10 USD
    let(:action) { SpreeCmCommissioner::PricingModel::Actions::CreateListingPriceAdjustment.new(calculator: calculator) }
    let(:rule) {
      SpreeCmCommissioner::PricingModel::Rules::FixedDate.new(
        preferred_match_policy: 'any',
        preferred_start_date: '2023-02-21',
        preferred_length: 2,
        vendor: vendor
      )
    }

    let!(:pricing_model) { create(:cm_pricing_model, rules: [rule], actions: [action]) }

    it 'only create and adjust vendor listing price on 2023-02-21, 2023-02-22' do
      context = described_class.call(
        from_date: '2023-02-20',
        to_date: '2023-02-24',
        vendor_id: vendor.id
      )

      listing_prices = context.vendor_listing_prices

      expect(listing_prices.size).to eq 5
      expect(listing_prices.pluck(:price).uniq).to eq [vendor.max_price]

      expect(listing_prices[0].display_adjustment_total.to_s).to eq '$0.00'
      expect(listing_prices[1].display_adjustment_total.to_s).to eq '-$10.00'
      expect(listing_prices[2].display_adjustment_total.to_s).to eq '-$10.00'
      expect(listing_prices[3].display_adjustment_total.to_s).to eq '$0.00'
      expect(listing_prices[4].display_adjustment_total.to_s).to eq '$0.00'

      expect(listing_prices[0].date).to eq '2023-02-20'.to_date
      expect(listing_prices[1].date).to eq '2023-02-21'.to_date
      expect(listing_prices[2].date).to eq '2023-02-22'.to_date
      expect(listing_prices[3].date).to eq '2023-02-23'.to_date
      expect(listing_prices[4].date).to eq '2023-02-24'.to_date

      expect(listing_prices[0].persisted?).to be false
      expect(listing_prices[1].persisted?).to be true
      expect(listing_prices[2].persisted?).to be true
      expect(listing_prices[3].persisted?).to be false
      expect(listing_prices[4].persisted?).to be false
    end
  end
end