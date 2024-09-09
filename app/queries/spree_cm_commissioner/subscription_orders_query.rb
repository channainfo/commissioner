module SpreeCmCommissioner
  class SubscriptionOrdersQuery
    attr_reader :from_date, :to_date, :vendor_id, :current_date, :spree_current_user

    def initialize(from_date:, to_date:, vendor_id:, spree_current_user:, current_date: Time.zone.today)
      @from_date = from_date
      @to_date = to_date
      @vendor_id = vendor_id
      @current_date = current_date
      @spree_current_user = spree_current_user
    end

    # when payment state != :paid &
    # order.line_item.to_date < now
    def overdues
      @overdues ||= query_builder.where.not(payment_state: :paid)
                                 .where('line_items.due_date < ?', current_date)
    end

    def query_builder
      if spree_current_user.has_spree_role?('admin')
        Spree::Order.subscription
                    .joins(:line_items)
                    .where(line_items: { vendor_id: vendor_id })
                    .where(created_at: from_date..to_date)
      else
        Spree::Order.subscription
                    .joins(:line_items)
                    .joins(subscription: :customer)
                    .where(line_items: { vendor_id: vendor_id })
                    .where(created_at: from_date..to_date)
                    .where(cm_customers: { place_id: spree_current_user.place_ids })
      end
    end
  end
end
