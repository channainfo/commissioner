module SpreeCmCommissioner
  module OptionTypeDecorator
    def self.prepended(base)
      def base.filter_separator
        "fo_"
      end

      base.include SpreeCmCommissioner::ParameterizeName
      base.include SpreeCmCommissioner::OptionTypeAttrType

      base.enum kind: %i[variant product vendor]

      base.validates :name, presence: true

      base.validate :kind_has_updated, on: :update, if: :kind_changed?

      base.scope :promoted, -> { where(promoted: true) }
      base.whitelisted_ransackable_attributes = %w[kind]
    end


    def filter_name
      # name.downcase.to_s
      # name_en = translations_by_locale[:en].name
      # "fo_#{name_en.downcase.to_s}"
      "#{Spree::OptionType.filter_separator}#{id}"
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
