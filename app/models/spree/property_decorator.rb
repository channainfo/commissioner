module Spree
  module PropertyDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ParameterizeName
    end
  end
end

Spree::Property.prepend(Spree::PropertyDecorator)
