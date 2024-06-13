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

      def preference_field_for(form, field, options)
        case options[:type]
        when :integer
          form.text_field(field, preference_field_options(options))
        when :boolean
          form.check_box(field, preference_field_options(options))
        when :string
          if %w[preferred_start_date preferred_end_date].include?(field)
            date_value = form.object.send(field)
            form.date_field(field, class: 'form-control js-quick-search-target js-filterable datepicker',
                                   data: { behavior: 'datepicker' },
                                   value: Date.parse(date_value)
            )
          else
            form.text_field(field, preference_field_options(options))
          end
        when :password
          form.password_field(field, preference_field_options(options))
        when :text
          form.text_area(field, preference_field_options(options))
        end
      end
    end
  end
end

Spree::Admin::BaseHelper.prepend(Spree::Admin::BaseHelperDecorator)
