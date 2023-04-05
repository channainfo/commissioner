module SpreeCmCommissioner
  module LineItemDecorator
    def self.prepended(base)
      base.before_save :update_vendor_id

      base.delegate :product_type, :accommodation?, :service?, :ecommerce?, to: :product
    end

    private

    def update_vendor_id
      self.vendor_id = variant.vendor_id
    end

    def subscription?
      order.subscription.present?
    end
  end
end

unless Spree::LineItem.included_modules.include?(SpreeCmCommissioner::LineItemDecorator)
  Spree::LineItem.prepend(SpreeCmCommissioner::LineItemDecorator)
end
