module SpreeCmCommissioner
  module OptionTypeDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ParameterizeName
      base.include SpreeCmCommissioner::OptionTypeAttrType

      base.enum kind: %i[variant product vendor]

      base.validates :name, presence: true

      base.validate :kind_has_updated, on: :update, if: :kind_changed?

      base.has_many :variants, through: :products

      base.scope :promoted, -> { where(promoted: true) }
      base.whitelisted_ransackable_attributes = %w[kind]
    end

    private

    def kind_has_updated
      errors.add(:kind, I18n.t('option_type.kind_validation', option_type_name: name))
    end
  end
end

unless Spree::OptionType.included_modules.include?(SpreeCmCommissioner::OptionTypeDecorator)
  Spree::OptionType.prepend(SpreeCmCommissioner::OptionTypeDecorator)
end
