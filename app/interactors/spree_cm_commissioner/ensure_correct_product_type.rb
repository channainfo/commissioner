module SpreeCmCommissioner
  class EnsureCorrectProductType < BaseInteractor
    def call
      Spree::Product
        .joins(variants_including_master: %i[inventory_items line_items])
        .where(
          'spree_variants.product_type != spree_products.product_type OR
          cm_inventory_items.product_type != spree_products.product_type OR
          spree_line_items.product_type != spree_products.product_type'
        ).distinct.find_each do |product|
        sync_product_type_for(product)
      end
    end

    def sync_product_type_for(product)
      product.variants_including_master.where.not(product_type: product.product_type).update_all(product_type: product.product_type) # rubocop:disable Rails/SkipsModelValidations
      product.line_items.where.not(product_type: product.product_type).update_all(product_type: product.product_type) # rubocop:disable Rails/SkipsModelValidations
      product.inventory_items.where.not(product_type: product.product_type).update_all(product_type: product.product_type) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
