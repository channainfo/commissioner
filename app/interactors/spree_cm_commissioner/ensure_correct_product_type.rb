module SpreeCmCommissioner
  class EnsureCorrectProductType < BaseInteractor
    def call
      Spree::Product
        .left_joins(variants_including_master: %i[inventory_items line_items])
        .where(
          'spree_variants.product_type IS NULL OR
          spree_variants.product_type != spree_products.product_type OR

          cm_inventory_items.product_type IS NULL OR
          cm_inventory_items.product_type != spree_products.product_type OR

          spree_line_items.product_type IS NULL OR
          spree_line_items.product_type != spree_products.product_type OR

          spree_products.product_type IS NOT NULL
          '
        )
        .distinct.find_each do |product|
        sync_product_type_for(product)
      end
    end

    def sync_product_type_for(product)
      product_type = Spree::Variant.product_types[product.product_type]

      product.variants_including_master
             .where('spree_variants.product_type IS NULL OR spree_variants.product_type != ?', product_type)
             .update_all(product_type: product_type) # rubocop:disable Rails/SkipsModelValidations

      product.line_items
             .where('spree_line_items.product_type IS NULL OR spree_line_items.product_type != ?', product_type)
             .update_all(product_type: product_type) # rubocop:disable Rails/SkipsModelValidations

      product.inventory_items
             .where('cm_inventory_items.product_type IS NULL OR cm_inventory_items.product_type != ?', product_type)
             .update_all(product_type: product_type) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
