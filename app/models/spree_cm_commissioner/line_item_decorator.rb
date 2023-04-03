module SpreeCmCommissioner
  module LineItemDecorator
    def self.prepended(base)
      base.before_save :update_vendor_id

      base.after_create :update_subscription_last_occurence, if: :subscription?

      base.delegate :product_type, :accommodation?, :service?, :ecommerce?, to: :product
    end

    private

    def update_vendor_id
      self.vendor_id = variant.vendor_id
    end

    def update_subscription_last_occurence
      order.subscription.update(last_occurence: from_date)
    end

    def subscription?
      order.subscription.present?
    end
  end
end

unless Spree::LineItem.included_modules.include?(SpreeCmCommissioner::LineItemDecorator)
  Spree::LineItem.prepend(SpreeCmCommissioner::LineItemDecorator)
end
