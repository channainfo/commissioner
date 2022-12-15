module Spree
  module OptionTypeDecorator
    def self.prepended(base)
      base.validate :is_master_has_updated, on: :update, if: :is_master_changed?
    end

    def is_master_has_updated
      errors.add(:is_master, I18n.t("option_type.is_master_validation", option_type_name: self.name))
    end
  end
end

Spree::OptionType.prepend Spree::OptionTypeDecorator