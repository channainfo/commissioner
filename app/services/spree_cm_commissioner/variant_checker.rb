module SpreeCmCommissioner
  class VariantChecker
    attr_reader :variant

    def initialize(variant_params, current_vendor)
      @product = Spree::Product.find_by(id: variant_params[:product_id])
      @variant_params = variant_params
      @current_vendor = current_vendor
    end

    def find_or_create_variant
      find_variant_by_sku || create_variant
    end

    private

    def find_variant_by_sku
      @variant = @product.variants.where(sku: variant_sku).first
    end

    def create_variant
      variant_creator = SpreeCmCommissioner::VariantCreator.new(@product, @variant_params, @current_vendor)
      variant_creator.create_variant
      @variant = variant_creator.variant
    end

    def variant_sku
      sku_generator = SpreeCmCommissioner::SkuGenerator.new(@product, @variant_params)
      sku_generator.generate_sku
    end
  end
end
