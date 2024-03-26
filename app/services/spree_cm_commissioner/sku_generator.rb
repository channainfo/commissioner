module SpreeCmCommissioner
  class SkuGenerator
    def initialize(product, variant_params)
      @product = product
      @variant_params = variant_params
    end

    def generate_sku
      return if @variant_params.nil? || @variant_params.blank?

      option_values = @variant_params[:option_value_ids].map { |id| Spree::OptionValue.find(id) }
      sku_parts = [product.name]

      option_values.each do |option_value|
        sku_parts << "#{option_value.option_type.name}-#{option_value.name}"
      end

      sku_parts << "price-#{@variant_params[:price]}"

      sku_parts.join('-').gsub(' ', '-').downcase
    end

    private

    def product
      @product ||= Spree::Product.find(@variant_params[:product_id])
    end
  end
end
