module Spree
  module BaseHelperDecorator
    def custom_product_storefront_resource_url(resource, options = {})
      if defined?(locale_param) && locale_param.present?
        options.merge!(locale: locale_param)
      end

      localize = if options[:locale].present?
                   "/#{options[:locale]}"
                 else
                   ''
                 end

      if resource.product_type == 'accommodation'
        "#{current_store.formatted_url + localize}/rooms/#{resource.slug}"
      elsif resource.product_type == 'ecommerce'
        "#{current_store.formatted_url + localize}/tickets/#{resource.slug}"
      else
        spree_storefront_resource_url(resource)
      end
    end
  end
end

Spree::BaseHelper.prepend(Spree::BaseHelperDecorator)
