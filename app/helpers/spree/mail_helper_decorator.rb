module Spree
  module MailHelperDecorator
    def user_full_name(order)
      order.name
    end

    def vendor(vendor_id)
      Spree::Vendor.find(vendor_id)
    end

    def full_address(stock_location)
      address = stock_location.address1 || stock_location.address2
      address += "  #{stock_location.city}" if stock_location.city.present?
      state_name = Spree::State.find(stock_location.state_id)&.name
      country_name = Spree::Country.find(stock_location.country_id)&.name
      "#{address} #{state_name}, #{country_name}"
    end

    def vendor_rating_stars(vendor)
      rating_stars = vendor.star_rating.to_i
      blank_stars = 5 - rating_stars
      rating_html = ''

      rating_stars.times.each do
        rating_html += "<i class='fa-solid fa-star rating'></i>"
      end

      blank_stars.times.each do
        rating_html += "<i class='fa-solid fa-star'></i>"
      end

      rating_html
    end

    def format_date(day)
      day.strftime('%A %d, %B, %Y')
    end

    def google_map(lat, lon)
      "https://www.google.com/maps/@#{lat},#{lon},15z?entry=ttu"
    end

    def generate_qr(order)
      qrcode = RQRCode::QRCode.new("https://bookme.plus/orders/#{order.number}")
      qrcode.as_svg(
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 5,
        standalone: true,
        use_path: true,
        viewbox: '0 0 20 10'
      )
    end
  end
end

Spree::MailHelper.prepend(Spree::MailHelperDecorator)
