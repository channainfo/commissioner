module SpreeCmCommissioner
  module PrototypeDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType

      base.has_many :variant_kind_option_types, -> { where(kind: :variant).order(:position) },
                    through: :option_type_prototypes, source: :option_type

      base.has_many :product_kind_option_types, -> { where(kind: :product).order(:position) },
                    through: :option_type_prototypes, source: :option_type

      base.has_many :option_values, through: :option_types
    end
  end
end

unless Spree::Prototype.included_modules.include?(SpreeCmCommissioner::PrototypeDecorator)
  Spree::Prototype.prepend SpreeCmCommissioner::PrototypeDecorator
end
