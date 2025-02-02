module Spree
  module V2
    module Tenant
      class ProductSerializer < BaseSerializer
        include ::Spree::Api::V2::DisplayMoneyHelper

        attributes :name, :description, :available_on, :slug,
                   :meta_description, :meta_keywords, :updated_at,
                   :sku, :barcode, :public_metadata

        attribute :purchasable do |product|
          value = product.purchasable?
          [true, false].include?(value) ? value : nil
        end

        attribute :in_stock do |product|
          value = product.in_stock?
          [true, false].include?(value) ? value : nil
        end

        attribute :backorderable do |product|
          value = product.backorderable?
          [true, false].include?(value) ? value : nil
        end

        attribute :available do |product|
          value = product.available?
          [true, false].include?(value) ? value : nil
        end

        attribute :currency do |_product, params|
          params[:currency]
        end

        attribute :price do |product, params|
          price(product, params[:currency])
        end

        attribute :display_price do |product, params|
          display_price(product, params[:currency])
        end

        attribute :compare_at_price do |product, params|
          compare_at_price(product, params[:currency])
        end

        attribute :display_compare_at_price do |product, params|
          display_compare_at_price(product, params[:currency])
        end

        has_one :venue, serializer: Spree::V2::Tenant::ProductPlaceSerializer

        has_many :variants
        has_many :option_types
        has_many :product_properties

        has_many :variant_kind_option_types, serializer: :option_type
        has_many :product_kind_option_types, serializer: :option_type
        has_many :promoted_option_types, serializer: :option_type
        has_many :possible_promotions, serializer: Spree::V2::Tenant::PromotionSerializer

        has_one :default_state, serializer: :state

        has_many :taxons, serializer: :taxon, record_type: :taxon do |object, params|
          object.taxons_for_store(params[:store]).order(:id)
        end

        # all images from all variants
        has_many :images,
                 object_method_name: :variant_images,
                 id_method_name: :variant_image_ids,
                 record_type: :image,
                 serializer: :image

        has_one :default_variant,
                object_method_name: :default_variant,
                id_method_name: :default_variant_id,
                record_type: :variant,
                serializer: :variant

        has_one :primary_variant,
                object_method_name: :master,
                id_method_name: :master_id,
                record_type: :variant,
                serializer: :variant
      end
    end
  end
end
