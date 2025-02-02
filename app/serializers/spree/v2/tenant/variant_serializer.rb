module Spree
  module V2
    module Tenant
      class VariantSerializer < BaseSerializer
        include ::Spree::Api::V2::DisplayMoneyHelper

        attributes :sku, :barcode, :weight, :height, :width, :depth, :is_master, :options_text, :public_metadata,
                   :need_confirmation, :product_type, :kyc, :allow_anonymous_booking,
                   :reminder_in_hours, :start_time, :delivery_option,
                   :number_of_guests, :max_quantity_per_order, :discontinue_on, :high_demand

        attribute :delivery_required, &:delivery_required?

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

        belongs_to :product
        has_many :images
        has_many :option_values

        has_many :stock_items, serializer: Spree::V2::Tenant::StockItemSerializer
      end
    end
  end
end
