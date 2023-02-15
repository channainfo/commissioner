module SpreeCmCommissioner
  module OptionTypeDecorator
    ATTRIBUTE_TYPES = %w(float integer string boolean date coordinate state_selection)

    def self.prepended(base)
      base.include SpreeCmCommissioner::ParameterizeName
      base.enum kind: %i[variant product vendor] 

      base.validates :name, presence: true
      base.validates :attr_type, inclusion: { in: ATTRIBUTE_TYPES }
      base.validates :attr_type, presence: true, if: :travel?
      base.validate :kind_has_updated, on: :update, if: :kind_changed?

      base.scope :promoted, -> { where(promoted: true) }
    end

    private

    def kind_has_updated
      errors.add(:kind, I18n.t("option_type.kind_validation", option_type_name: self.name))
    end
  end
end

unless Spree::OptionType.included_modules.include?(SpreeCmCommissioner::OptionTypeDecorator)
  Spree::OptionType.prepend(SpreeCmCommissioner::OptionTypeDecorator)
end
