module SpreeCmCommissioner
  class CalendarEvent
    attr_reader :from_date, :to_date, :title, :options

    def initialize(from_date:, to_date:, title:, options:)
      @from_date = from_date
      @to_date = to_date
      @title = title
      @options = options
    end

    def self.from_orders(orders)
      orders.map do |order|
        CalendarEvent.new(
          from_date: order.line_items.minimum(:from_date),
          to_date: order.line_items.maximum(:to_date),
          title: Spree.t(:order),
          options: {
            popover: 'shared/calendar/order_popover',
            classes: ['bg-primary'],
            order: order
          }
        )
      end
    end

    def self.from_listing_prices(listing_prices)
      listing_prices.filter_map do |listing_price|
        if listing_price.persisted?
          CalendarEvent.new(
            from_date: listing_price.date,
            to_date: listing_price.date,
            title: Spree.t(:listing_price),
            options: {
              popover: 'shared/calendar/listing_price_popover',
              classes: ['bg-success p-2'],
              listing_price: listing_price
            }
          )
        end
      end
    end
  end
end
