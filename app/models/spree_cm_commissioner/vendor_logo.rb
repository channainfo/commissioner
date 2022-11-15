module SpreeCmCommissioner
  class VendorLogo < Spree::Asset
    include Spree::Image::Configuration::ActiveStorage
    include Rails.application.routes.url_helpers

    def styles
      logo_styles.map do |_, size|
        width, height = size[/(\d+)x(\d+)/].split('x')

        {
          url: polymorphic_path(attachment.variant(resize: size), only_path: true),
          width: width,
          height: height
        }
      end
    end

    private

    def logo_styles
      {
        thumb: '60x60>',
        small: '180x180>'
      }
    end
  end
end
