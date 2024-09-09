module SpreeCmCommissioner
  module Feed
    def self.query_active_products
      Spree::Product.not_discontinued.where('spree_products.available_on <= ?', Time.current)
    end
  end
end
