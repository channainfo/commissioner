module SpreeCmCommissioner
  module ImageDecorator
    # override
    def styles
      size = '1200x1200'
      width, height = size.split('x')

      [
        {
          url: cdn_image_url(attachment.variant(resize_to_limit: [width.to_i, height.to_i])),
          width: width,
          height: height
        }
      ]
    end

    def asset_styles
      self.class.styles.merge({ product_zoomed: '1200x1200>' })
    end
  end
end

Spree::Image.prepend(SpreeCmCommissioner::ImageDecorator) unless Spree::Image.included_modules.include?(SpreeCmCommissioner::ImageDecorator)
