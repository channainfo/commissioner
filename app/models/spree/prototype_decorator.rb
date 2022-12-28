# frozen_string_literal: true

module Spree
  module PrototypeDecorator
    def self.prepended(base)
      base.belongs_to :product_type, class_name: 'SpreeCmCommissioner::ProductType'
    end
  end
end

Spree::Prototype.prepend Spree::PrototypeDecorator