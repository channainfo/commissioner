module SpreeCmCommissioner
  module V2
    module Storefront
      module IconSerializerDecorator
        def self.prepended(base)
          base.attributes :url
        end
      end
    end
  end
end

unless Spree::V2::Storefront::IconSerializer.included_modules.include?(SpreeCmCommissioner::V2::Storefront::IconSerializerDecorator)
  Spree::V2::Storefront::IconSerializer.prepend SpreeCmCommissioner::V2::Storefront::IconSerializerDecorator
end
