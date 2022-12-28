module Spree
  module OptionTypeDecorator
    ATTRIBUTE_TYPES = %w(float integer string boolean date coordinate state_selection)

    def self.prepended(base)
      base.include SpreeCmCommissioner::DashCaseName

      base.validates :name, presence: true
      base.validates :attr_type, inclusion: { in: ATTRIBUTE_TYPES }
      base.validates :attr_type, presence: true, if: :travel?

      base.validate :is_master_has_updated, on: :update, if: :is_master_changed?
    end

    private

    def is_master_has_updated
      errors.add(:is_master, I18n.t("option_type.is_master_validation", option_type_name: self.name))
    end
  end
end

Spree::OptionType.prepend Spree::OptionTypeDecorator