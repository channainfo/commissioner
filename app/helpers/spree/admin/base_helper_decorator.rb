module Spree
  module Admin
    module BaseHelperDecorator
      def render_vector_icon(asset_path, _options = {})
        return inline_svg_tag asset_path, size: '24px*24px' if asset_path.end_with?('.svg')

        image_tag asset_path, width: '24px'
      end

      def render_escape_html(render_payload)
        Rack::Utils.escape_html(render(render_payload))
      end
    end
  end
end

Spree::Admin::BaseHelper.prepend(Spree::Admin::BaseHelperDecorator)
