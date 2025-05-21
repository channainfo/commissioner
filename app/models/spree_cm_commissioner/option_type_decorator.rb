module SpreeCmCommissioner
  module OptionTypeDecorator
    RULES_OPTION_TYPE_NAME = 'rules'.freeze

    def self.prepended(base)
      base.include SpreeCmCommissioner::ParameterizeName
      base.include SpreeCmCommissioner::OptionTypeAttrType

      base.enum kind: %i[variant product vendor vehicle_type transit]

      base.validates :name, presence: true

      base.validate :kind_has_updated, on: :update, if: :kind_changed?

      base.has_many :variants, through: :products

      base.scope :promoted, -> { where(promoted: true) }
      base.whitelisted_ransackable_attributes = %w[kind]

      def base.amenities
        Spree::OptionType.where(kind: 'vehicle_type', name: 'amenities', presentation: 'Amenities', attr_type: 'amenity').first_or_create
      end

      def base.vehicle
        Spree::OptionType.where(presentation: 'vehicle', attr_type: 'vehicle_id', kind: 'variant',
                                name: 'vehicle'
        ).first_or_create
      end

      def base.rules_option_type
        Spree::OptionType.find_by(name: RULES_OPTION_TYPE_NAME)
      end
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
