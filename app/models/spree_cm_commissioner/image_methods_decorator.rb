module SpreeCmCommissioner
  module ImageMethodsDecorator
    # rubocop:disable Lint/UnusedMethodArgument
    def generate_url(size:, gravity: 'centre', quality: 80, background: [0, 0, 0])
      # rubocop:enable Lint/UnusedMethodArgument
      return if size.blank?

      size = size.gsub(/\s+/, '')

      return unless size.match(/(\d+)x(\d+)/)

      width, height = size.split('x').map(&:to_i)

      cdn_image_url(attachment.variant(resize_to_limit: [width, height], saver: { quality: quality }))
    end
  end
end

unless Spree::ImageMethods.included_modules.include?(SpreeCmCommissioner::ImageMethodsDecorator)
  Spree::ImageMethods.prepend(SpreeCmCommissioner::ImageMethodsDecorator)
end
