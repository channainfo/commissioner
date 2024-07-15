module SpreeCmCommissioner
  class Subscription < SpreeCmCommissioner::Base
    self.locking_column = :version

    enum status: { :active => 0, :suspended => 1, :inactive => 2 }

    belongs_to :variant, class_name: 'Spree::Variant'
    belongs_to :customer, class_name: 'SpreeCmCommissioner::Customer'

    has_many :orders, -> { order(:created_at) }, class_name: 'Spree::Order', dependent: :nullify
    has_many :line_items, through: :orders, class_name: 'Spree::LineItem'

    validates :start_date, :status, presence: true

    with_options unless: :persisted? do
      validate :quanitiy_is_not_nil?
      validate :variant_in_stock?
      validate :product_active?
      validate :variant_subscribed?
    end

    after_create :create_order
    after_commit :update_customer_active_subscriptions_count

    def create_order
      SpreeCmCommissioner::SubscribedOrderCreator.call(subscription: self)
    end

    def quanitiy_is_not_nil?
      return false unless quantity.nil? || quantity.zero?

      errors.add(:subscription, I18n.t('spree..billing.subscription.quantity_is_missing'))
    end

    def variant_in_stock?
      return false if variant.in_stock?

      errors.add(:variant, I18n.t('variant.validation.out_of_stock', variant_name: variant.name))
    end

    def variant_subscribed?
      return false if customer.subscriptions.where(variant: variant).blank?

      errors.add(:variant, I18n.t('variant.validation.subscribed', product_name: variant.sku))
    end

    def product_active?
      return false if variant.product.active?

      errors.add(:product, I18n.t('product.validation.not_active', product_name: product.name))
    end

    def months_count
      variant.month
    end

    def display_total_price
      total_price = variant.price * quantity
      Spree::Money.new(total_price.to_i, currency: variant.currency).to_s
    end

    def renewal_date
      return start_date if last_occurence.blank?

      last_occurence + months_count.months
    end

    def update_customer_active_subscriptions_count
      customer.update(active_subscriptions_count: customer.subscriptions.where(status: 'active').count)
    end
  end
end
