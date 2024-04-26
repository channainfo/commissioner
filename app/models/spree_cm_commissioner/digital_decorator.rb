module SpreeCmCommissioner
  module DigitalDecorator
    def url
      ::Rails.application.routes.url_helpers.cdn_image_url(attachment)
    end
  end
end

Spree::Digital.prepend(SpreeCmCommissioner::DigitalDecorator) unless Spree::Digital.included_modules.include?(SpreeCmCommissioner::DigitalDecorator)
