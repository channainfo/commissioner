module SpreeCmCommissioner
  class VendorPhoto < Spree::Asset
    include Spree::Image::Configuration::ActiveStorage
    include Rails.application.routes.url_helpers
    include ::Spree::ImageMethods

    def styles
      mobile_styles.map do |_, size|
        width, height = size[/(\d+)x(\d+)/].split('x')

        {
          url: polymorphic_path(attachment.variant(resize: size), only_path: true),
          width: width,
          height: height
        }
      end
    end

    # 4x3
    def mobile_styles
      {
        mini: "160x120>",
        small: "480x360>",
        medium: "960x720>"
      }
    end
  end
end