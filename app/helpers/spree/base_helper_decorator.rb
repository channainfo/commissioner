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

    def custom_product_line_item_url(line_item, options = {})
      if defined?(locale_param) && locale_param.present?
        options.merge!(locale: locale_param)
      end

      localize = if options[:locale].present?
                   "/#{options[:locale]}"
                 else
                   ''
                 end

      line_item = Spree::LineItem.find(line_item.id)
      jwt_token = SpreeCmCommissioner::LineItemJwtToken.encode(line_item)

      return if line_item.number.blank? && jwt_token.blank?

      "#{current_store.formatted_url + localize}/a/#{line_item.number}?ak=#{jwt_token}"
    end
  end
end

Spree::BaseHelper.prepend(Spree::BaseHelperDecorator)
