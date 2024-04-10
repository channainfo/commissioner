module SpreeCmCommissioner
  module PriceableConcern
    extend ActiveSupport::Concern

    included do
      has_many :prices, as: :priceable, class_name: 'Spree::Price', dependent: :destroy
    end

    def price_in(currency)
      currency = currency&.upcase
      cache_key = "spree/prices/#{cache_key_with_version}/price_in/#{currency}"

      Rails.cache.fetch(cache_key) { find_or_build_price(currency) } || find_or_build_price(currency)
    rescue TypeError # when mocking in rspec, it raised TypeError: singleton can't be dumped
      find_or_build_price(currency)
    end

    def find_or_build_price(currency)
      if prices.loaded?
        prices.detect { |price| price.currency == currency } || prices.build(currency: currency)
      else
        prices.find_or_initialize_by(currency: currency)
      end
    end
  end
end
