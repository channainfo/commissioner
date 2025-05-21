module SpreeCmCommissioner
  class ProductEventIdToChildrenSyncerJob < ApplicationUniqueJob
    def perform(product_id)
      product = Spree::Product.find(product_id)
      SpreeCmCommissioner::ProductEventIdToChildrenSyncer.call(product: product)
    end
  end
end
