module Spree
  module V2
    module Tenant
      class VariantSerializer < BaseSerializer
        include Spree::Api::V2::DisplayMoneyHelper
        attributes :sku, :barcode, :weight, :height, :width, :depth, :is_master, :options_text, :public_metadata
        attribute :purchasable, &:purchasable?
        attribute :in_stock, &:in_stock?
        attribute :backorderable, &:backorderable?

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

        attributes :need_confirmation, :product_type, :kyc, :allow_anonymous_booking,
                   :reminder_in_hours, :start_time, :delivery_option,
                   :number_of_guests, :max_quantity_per_order, :discontinue_on, :high_demand

        attribute :delivery_required, &:delivery_required?

        belongs_to :product, serializer: Spree::V2::Storefront::ProductSerializer

        has_many :images, serializer: Spree::V2::Tenant::ImageSerializer
        has_many :option_values, serializer: Spree::V2::Tenant::OptionValueSerializer
        has_many :stock_locations, serializer: Spree::V2::Tenant::StockLocationSerializer
        has_many :stock_items, serializer: Spree::V2::Tenant::StockItemSerializer
      end
    end
  end
end
