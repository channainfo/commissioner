FactoryBot.define do
  factory :cm_listing_price, class: SpreeCmCommissioner::ListingPrice do
    price { 10.0 }

    date { '2022-12-27'.to_date }
    currency { Spree::Store.default.default_currency }

    price_source { |l| create(:product, price: l.price) }
  end
end
