module SpreeCmCommissioner
  class FeatureImage < Spree::Asset
    include Spree::Image::Configuration::ActiveStorage
    include Rails.application.routes.url_helpers

    def mobile_styles
      self.class.mobile_styles.each_with_object({}) do |(key, size), results|
        results[key] = style(key) if size
      end
    end
  end
end
