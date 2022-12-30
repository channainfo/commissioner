module Spree
  module PrototypeDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ProductType
    end
  end
end

Spree::Prototype.prepend Spree::PrototypeDecorator