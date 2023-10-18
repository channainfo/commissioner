# 🎫--- [NEW ORDER FROM BOOKME+] ---

# Order Number:
# R221881958

# [ x1 ]
# Product Name: Deluxe River View Bungalow
# Options: Payment: pay-at-hotel, Adults: 2, and Kids: 2
# Date: October 19, 2023 ---> October 21, 2023
#
# [ x2 ]
# Product Name: River Amazing View
# Options: Payment: pay-at-hotel, Adults: 2, and Kids: 2
# Date: October 19, 2023 ---> October 21, 2023

# Customer Info
# Name: Thea Choem
# Tel: 0123468889
#
module SpreeCmCommissioner
  class OrderTelegramMessageFactory < TelegramMessageFactory
    attr_reader :order, :vendor

    def initialize(title:, order:, vendor: nil)
      @order = order
      @vendor = vendor

      super(title: title)
    end

    def selected_line_items
      return order.line_items.for_vendor(vendor) if vendor.present?

      order.line_items
    end

    def body
      text = []
      text << "Order Number:\n<code>#{order.number}</code>\n"
      text << selected_line_items.map { |item| line_item_content(item) }.compact.join("\n")
      text.compact.join("\n")
    end

    def line_item_content(line_item)
      text = []

      text << "[ x#{line_item.quantity} ]"
      text << "Product Name: #{line_item.product.name}"
      text << "Options: #{line_item.options_text}" if line_item.options_text.present?
      text << "Date: #{pretty_date(line_item.from_date)} ---> #{pretty_date(line_item.to_date)}" if line_item.date_present?
      text << "Vendor: #{line_item.vendor.name}" if line_item.vendor&.name.present? && vendor.blank?

      text.compact.join("\n")
    end

    def footer
      text = []

      text << '<b>Customer Info</b>'
      text << "Name: #{order.name}"
      text << "Tel: #{order.phone_number}"
      text << "Email: #{order.email}" if order.email.present?

      text.compact.join("\n")
    end
  end
end
