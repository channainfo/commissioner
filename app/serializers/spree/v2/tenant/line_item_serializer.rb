module Spree
  module V2
    module Tenant
      class LineItemSerializer < BaseSerializer
        attributes :name, :quantity, :price, :slug, :options_text, :currency,
                   :display_price, :total, :display_total, :adjustment_total,
                   :display_adjustment_total, :additional_tax_total, :discounted_amount,
                   :display_discounted_amount, :display_additional_tax_total, :promo_total,
                   :display_promo_total, :included_tax_total, :display_included_tax_total,
                   :from_date, :to_date, :need_confirmation, :product_type, :event_status, :amount,
                   :display_amount, :number, :qr_data, :kyc, :kyc_fields, :remaining_total_guests, :number_of_guests,
                   :completion_steps, :available_social_contact_platforms, :allow_anonymous_booking,
                   :discontinue_on, :high_demand, :jwt_token, :pre_tax_amount, :display_pre_tax_amount, :public_metadata

        attribute :required_self_check_in_location, &:required_self_check_in_location?
        attribute :allowed_self_check_in, &:allowed_self_check_in?
        attribute :allowed_upload_later, &:allowed_upload_later?
        attribute :delivery_required, &:delivery_required?
        attribute :sufficient_stock, &:sufficient_stock?

        has_one :vendor, serializer: Spree::V2::Tenant::VendorSerializer
        has_one :product, serializer: Spree::V2::Storefront::ProductSerializer

        belongs_to :variant, serializer: Spree::V2::Tenant::VariantSerializer
        belongs_to :order, serializer: Spree::V2::Tenant::OrderSerializer

        has_many :digital_links, serializer: Spree::V2::Tenant::DigitalLinkSerializer
        has_many :guests, serializer: Spree::V2::Tenant::GuestSerializer

        # completion_steps updates frequently
        cache_options store: nil
      end
    end
  end
end
