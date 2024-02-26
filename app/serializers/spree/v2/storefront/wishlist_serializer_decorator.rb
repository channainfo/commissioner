module Spree
  module V2
    module Storefront
      module WishedItemSerializerDecorator
        def self.prepended(base)
          base.attributes :quantity, :price, :total, :display_price, :display_total
          base.belongs_to :variant
        end

        def total
          (object.quantity * object.variant.price).to_s
        end

        def display_total
          Spree::Money.new(total, currency: object.variant.currency).to_s
        end
      end
    end
  end
end

Spree::V2::Storefront::WishedItemSerializer.prepend(Spree::V2::Storefront::WishedItemSerializerDecorator)
