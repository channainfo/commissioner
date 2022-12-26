 module Spree
  module VariantDecorator
    def self.prepended(base)
      base.has_one :product_type, class_name: 'SpreeCmCommissioner::ProductType', through: :product

      base.after_commit :update_vendor_price
      base.validate :validate_option_types
    end

    def selected_option_value_ids
      option_value_variants.pluck(:option_value_id)
    end

    private

    def update_vendor_price
      if product_type&.name == 'Property'
        vendor.update(min_price: price) if price < vendor.min_price
        vendor.update(max_price: price) if price > vendor.max_price
      end
    end

    def validate_option_types
      variant = self

      option_values.each do |option_value|
        option_type = option_value.option_type

        if variant.is_master? && !option_type.is_master?
          message = I18n.t("variant.validation.option_type_is_not_master", option_type_name: option_type.name, option_value_name: option_value.name)
          errors.add(:attr_type, message) 
        end

        if !variant.is_master? && option_type.is_master?
          message = I18n.t("variant.validation.option_type_is_master", option_type_name: option_type.name, option_value_name: option_value.name)
          errors.add(:attr_type, message)
        end
      end
    end
  end
end

Spree::Variant.prepend(Spree::VariantDecorator)