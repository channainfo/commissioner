module SpreeCmCommissioner
  module Priceable
    extend ActiveSupport::Concern

    included do
      has_many :prices, as: :priceable, class_name: 'Spree::Price', dependent: :destroy
    end

    def price_in(currency)
      currency = currency&.upcase
      cache_key = "spree/prices/#{cache_key_with_version}/price_in/#{currency}"

      Rails.cache.fetch(cache_key) { find_or_build_price(currency) } || find_or_build_price(currency)

    # it raised TypeError: singleton can't be dumped, mean that it can't cache singleton class.
    # it happens only on rspec.
    rescue TypeError
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
