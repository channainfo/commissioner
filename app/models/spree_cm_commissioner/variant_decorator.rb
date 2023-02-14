module SpreeCmCommissioner
  module VariantDecorator
    def self.prepended(base)
      base.after_commit :update_vendor_price
      base.after_save   :update_vendor_total_inventory, if: :saved_change_to_permanent_stock?
      base.validate     :validate_option_types
    end

    def selected_option_value_ids
      option_value_variants.pluck(:option_value_id)
    end

    private

    def update_vendor_price
      if product&.product_type == vendor.primary_product_type
        vendor.update(min_price: price) if price < vendor.min_price
        vendor.update(max_price: price) if price > vendor.max_price
      end
    end

    def update_vendor_total_inventory
      SpreeCmCommissioner::VendorJob.perform_later(vendor.id)
    end

    def validate_option_types
      variant = self

      option_values.each do |option_value|
        option_type = option_value.option_type

        if variant.is_master? && !option_type.product?
          message = I18n.t("variant.validation.option_type_is_not_product", option_type_name: option_type.name, option_value_name: option_value.name)
          errors.add(:attr_type, message) 
        end

        if !variant.is_master? && !option_type.variant?
          message = I18n.t("variant.validation.option_type_is_not_variant", option_type_name: option_type.name, option_value_name: option_value.name)
          errors.add(:attr_type, message)
        end
      end
    end
  end
end

unless Spree::Variant.included_modules.include?(SpreeCmCommissioner::VariantDecorator)
  Spree::Variant.prepend(SpreeCmCommissioner::VariantDecorator)
end
