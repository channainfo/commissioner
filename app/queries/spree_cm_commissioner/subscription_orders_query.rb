module SpreeCmCommissioner
  class SubscriptionOrdersQuery
    attr_reader :from_date, :to_date, :vendor_id, :current_date

    def initialize(from_date:, to_date:, vendor_id:, current_date: Time.zone.today)
      @from_date = from_date
      @to_date = to_date
      @vendor_id = vendor_id
      @current_date = current_date
    end

    # when payment state != :paid &
    # order.line_item.to_date < now
    def overdues
      @overdues ||= query_builder.where.not(payment_state: :paid)
                                 .where('line_items.due_date < ?', current_date)
    end

    def query_builder
      Spree::Order.subscription
                  .joins(:line_items)
                  .where(line_items: { vendor_id: vendor_id, from_date: from_date..to_date })
    end
  end
end
