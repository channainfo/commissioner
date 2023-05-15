module SpreeCmCommissioner
  class Asset < Spree::Asset
    include Spree::Image::Configuration::ActiveStorage
    include Rails.application.routes.url_helpers
    include ::Spree::ImageMethods

    def styles
      asset_styles.map do |_, size|
        width, height = size[/(\d+)x(\d+)/].split('x')

        {
          url: url_for(attachment.variant(resize_to_limit: [width.to_i, height.to_i])),
          width: width,
          height: height
        }
      end
    end

    protected

    def asset_styles
      self.class.styles
    end
  end
end
