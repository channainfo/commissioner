module Spree
  module MailHelperDecorator
    def user_full_name(order)
      order.name
    end

    def vendor(vendor_id)
      Spree::Vendor.find(vendor_id)
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
  end
end

Spree::MailHelper.prepend(Spree::MailHelperDecorator)
