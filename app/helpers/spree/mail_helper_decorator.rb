module Spree
  module MailHelperDecorator
    def user_full_name(order)
      order.name
    end

    def vendor(vendor_id)
      Spree::Vendor.find(vendor_id)
    end

    def format_date(day)
      day&.strftime('%A %d, %B, %Y')
    end

    def google_map(lat, lon)
      "https://www.google.com/maps/@#{lat},#{lon},15z?entry=ttu"
    end

    def notice_info(current_store, product_type)
      notice_page = current_store.cms_pages.find_by(slug: 'hotel-notice')
      notice_page = current_store.cms_pages.find_by(slug: 'event-notice') if product_type == 'ecommerce'
      notice_page.content
    end
  end
end

Spree::MailHelper.prepend(Spree::MailHelperDecorator)
