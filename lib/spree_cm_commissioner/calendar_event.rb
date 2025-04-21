module SpreeCmCommissioner
  class CalendarEvent
    attr_reader :from_date, :to_date, :title, :options

    def initialize(from_date:, to_date:, title: nil, options: nil)
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

    def self.from_inventory_items(inventory_items)
      inventory_items.map do |item|
        CalendarEvent.new(
          from_date: item.inventory_date,
          to_date: item.inventory_date,
          options: { inventory_item: item }
        )
      end
    end
  end
end
