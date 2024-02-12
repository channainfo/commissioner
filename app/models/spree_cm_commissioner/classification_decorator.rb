module SpreeCmCommissioner
  module ClassificationDecorator
    def self.prepended(base)
      base.has_many :line_items, through: :product
      base.has_many :complete_line_items, -> { complete }, through: :product
    end
  end
end

unless Spree::Classification.included_modules.include?(SpreeCmCommissioner::ClassificationDecorator)
  Spree::Classification.prepend(SpreeCmCommissioner::ClassificationDecorator)
end
