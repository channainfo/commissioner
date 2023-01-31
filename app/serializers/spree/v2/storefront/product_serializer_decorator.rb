module Spree
  module V2
    module Storefront
      module ProductSerializerDecorator
        def self.prepended(base)
          base.has_many :variant_kind_option_types, serializer: :option_type
          base.has_many :product_kind_option_types, serializer: :option_type
          base.has_many :promoted_option_types, serializer: :option_type

          # current_store only exist in controller
          base.has_many :taxons, serializer: :taxon, record_type: :taxon do |object, params|
            if params[:store].present?
              object.taxons_for_store(params[:store])
            else
              object.taxons
            end
          end
        end
      end
    end
  end
end

Spree::V2::Storefront::ProductSerializer.prepend Spree::V2::Storefront::ProductSerializerDecorator