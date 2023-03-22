module SpreeCmCommissioner
  class Subscription < SpreeCmCommissioner::Base
    enum status: { :active => 0, :suspended => 1, :inactive => 2 }

    belongs_to :variant, class_name: 'Spree::Variant'
    belongs_to :customer, class_name: 'SpreeCmCommissioner::Customer'

    has_many :orders, class_name: 'Spree::Order'

    validates :start_date, :status, presence: true

    validate :variant_in_stock?
    validate :product_active?

    after_create :create_order

    def create_order
      SpreeCmCommissioner::SubscribedOrderCreator.call(subscription: self)
    end

    def variant_in_stock?
      return if variant.in_stock?

      errors.add(:variant, I18n.t('variant.validation.out_of_stock', variant_name: variant.name))
    end

    def product_active?
      return if variant.product.active?

      errors.add(:product, I18n.t('product.validation.not_active', product_name: product.name))
    end

    def months_count
      month_option_type = variant.product.option_types.find_by(name: 'month')
      month_option_value = variant.option_values.find_by(option_type_id: month_option_type.id)

      month_option_value.presentation.to_i
    end
  end
end
