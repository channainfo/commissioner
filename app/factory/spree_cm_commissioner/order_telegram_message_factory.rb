# 🎫 --- [NEW ORDER] ---
#
# Order Number:
# <code>R621016753</code>
#
# [ x1 ]
# <b>5km Running Ticket</b>
# <i>👉 Distance: 5km, T-shirt: M</i>
# <i>🗓️ Nov 15, 2023</i>
# <i>🏪 Temple Run with Sai</i>
#
# [ x2 ]
# <b>5km Running Ticket</b>
# <i>👉 Distance: 5km, T-shirt: S</i>
# <i>🗓️ Nov 15, 2023 -> Nov 17, 2023</i>
# <i>🏪 Temple Run with Sai</i>
#
# <b>🙍 Customer Info</b>
# Name: Vaneath Awesome
# Tel: <code>+85570760548</code>
# Email: <code>admin_dev@cm.com</code>

module SpreeCmCommissioner
  class OrderTelegramMessageFactory < TelegramMessageFactory
    attr_reader :order, :vendor, :show_details_link

    def initialize(title:, order:, subtitle: nil, show_details_link: nil, vendor: nil)
      @order = order
      @vendor = vendor
      @show_details_link = show_details_link || false

      super(title: title, subtitle: subtitle)
    end

    def selected_line_items
      return order.line_items.for_vendor(vendor) if vendor.present?

      order.line_items
    end

    # override
    def body
      text = []
      text << "Order Number:\n#{inline_code(order.number)}\n"
      text << selected_line_items.map { |item| line_item_content(item) }.compact.join("\n\n")
      text.compact.join("\n")
    end

    def line_item_content(line_item)
      text = []

      text << "[ x#{line_item.quantity} ]"
      text << bold(line_item.product.name.to_s)
      text << italic("👉 #{line_item.options_text}") if line_item.options_text.present?
      text << italic(pretty_date_for(line_item)) if pretty_date_for(line_item).present?
      text << italic("🏪 #{line_item.vendor.name}") if line_item.vendor&.name.present? && vendor.blank?

      text.compact.join("\n")
    end

    def pretty_date_for(line_item)
      return nil unless line_item.date_present?

      from_date = pretty_date(line_item.from_date)
      to_date = pretty_date(line_item.to_date)

      if from_date == to_date
        "🗓️ #{from_date}"
      else
        "🗓️ #{from_date} -> #{to_date}"
      end
    end

    # override
    def footer
      text = []

      text << bold('🙍 Customer Info')
      text << "Name: #{order.name}"
      text << "Tel: #{inline_code(order.intel_phone_number || order.phone_number)}"
      text << "Email: #{inline_code(order.email)}" if order.email.present?

      if show_details_link
        text << ''
        text << "<a href='#{Spree::Store.default.url}/orders/#{order.qr_data}'>More details</a>"
      end

      text.compact.join("\n")
    end
  end
end
