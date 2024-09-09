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

      text << bold(line_item.product.name.to_s)
      text << "Quantity: #{line_item.quantity}"
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

      if show_details_link && order.guests.any?
        text << ''
        text << 'View Tickets:'
        text += generate_guests_links(order.guests)
      end

      text.compact.join("\n")
    end

    # Result:
    # | No. A24 | No. A24 |
    # | No. A24 | No. A24 |
    # | No. A24 | No. A24 |
    # | No. A24 | No. A24 |
    # | No. A24 | No. A24 |
    # | No. A24 |
    def generate_guests_links(guests, guests_per_row = 2)
      rows = (guests.size.to_f / guests_per_row).ceil
      formatted_rows = []

      rows.times do |i|
        row_guests = guests.slice(i * guests_per_row, guests_per_row)
        formatted_row = row_guests.map do |guest|
          button_label = guest.seat_number.present? ? "No. #{guest.seat_number}" : "No. #{guest.formatted_bib_number || 'N/A'}"
          link = Rails.application.routes.url_helpers.guest_cards_url(guest.token)
          "| <a href='#{link}'>#{button_label}</a>"
        end.join(' ')

        formatted_rows << ("#{formatted_row} |")
      end

      formatted_rows
    end
  end
end
