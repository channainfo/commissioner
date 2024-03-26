module SpreeCmCommissioner
  class VariantCreator
    attr_reader :variant

    def initialize(product, variant_params, current_vendor)
      @product = product
      @variant_params = variant_params
      @current_vendor = current_vendor
    end

    def create_variant
      @variant = @product.variants.build
      generate_sku
      set_variant_attributes
      @variant.save
      @variant
    end

    private

    def generate_sku
      sku_generator = SpreeCmCommissioner::SkuGenerator.new(@product, @variant_params)
      @variant.sku = sku_generator.generate_sku
    end

    def set_variant_attributes
      @variant.option_value_ids = @variant_params[:option_value_ids]
      @variant.price = @variant_params[:price]
      stock_item = @variant.stock_items.build(stock_location_id: stock_location, count_on_hand: 1, backorderable: false)
      stock_item.save
    end

    def stock_location
      @stock_location ||= Spree::StockLocation.find_by!(vendor_id: @current_vendor.id).id
    end
  end
end
