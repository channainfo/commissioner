module Spree
  module Admin
    module BaseHelperDecorator
      def render_vector_icon(asset_path, _options = {})
        return inline_svg_tag asset_path, size: '24px*24px' if asset_path.end_with?('.svg')

        image_tag asset_path, width: '24px'
      end
    end
  end
end

Spree::Admin::BaseHelper.prepend(Spree::Admin::BaseHelperDecorator)
