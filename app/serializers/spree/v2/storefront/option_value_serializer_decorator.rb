# More about asset urls:
# https://github.com/casunlight/rails/blob/master/actionview/lib/action_view/helpers/asset_url_helper.rb

module Spree
  module V2
    module Storefront
      module OptionValueSerializerDecorator
        def self.prepended(base)
          base.attribute :display_icon do |option_value|
            ActionController::Base.helpers.image_url(option_value.display_icon)
          rescue StandardError
            nil
          end
        end
      end
    end
  end
end

Spree::V2::Storefront::OptionValueSerializer.prepend Spree::V2::Storefront::OptionValueSerializerDecorator
