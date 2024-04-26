module SpreeCmCommissioner
  module IconDecorator
    def url
      ::Rails.application.routes.url_helpers.cdn_image_url(attachment)
    end
  end
end

Spree::Icon.prepend(SpreeCmCommissioner::IconDecorator) unless Spree::Icon.included_modules.include?(SpreeCmCommissioner::IconDecorator)
