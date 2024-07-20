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

      # override
      def preference_field_for(form, field, options)
        case field
        when 'preferred_start_date', 'preferred_end_date'
          value = parse_date(form.object.send(field))
          return form.date_field(field, class: 'form-control datepicker bg-transparent', value: value, 'data-enable-time': 'true')
        end
        super
      end

      def parse_date(date)
        DateTime.parse(date)
      rescue StandardError
        nil
      end
    end
  end
end

Spree::Admin::BaseHelper.prepend(Spree::Admin::BaseHelperDecorator)
