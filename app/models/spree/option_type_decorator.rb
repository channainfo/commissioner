module Spree
  module OptionTypeDecorator
    def self.prepended(base)
      base.validates_uniqueness_of :name
      base.validates :attr_type, presence: true, if: :travel?

      base.validate :is_master_has_updated, on: :update, if: :is_master_changed?

      base.after_create :create_default_option_value
    end

    def is_master_has_updated
      errors.add(:is_master, I18n.t("option_type.is_master_validation", option_type_name: self.name))
    end

    def create_default_option_value
      return unless attr_type != 'selection' && option_values.empty? && travel
      Spree::OptionValue.create(name: name, presentation: presentation, option_type_id: id)
    end
  end
end

Spree::OptionType.prepend Spree::OptionTypeDecorator