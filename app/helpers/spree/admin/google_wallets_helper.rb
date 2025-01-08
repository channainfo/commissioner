module Spree
  module Admin
    module GoogleWalletsHelper
      # override
      def preference_fields(object, form)
        return unless object.respond_to?(:preferences)

        fields = object.preferences.keys.map do |key|
          next unless object.has_preference?(key)
          next if %i[response verified_at].include?(key)

          render_preference_field(object, form, key)
        end
        safe_join(fields)
      end

      private

      def render_preference_field(object, form, key)
        case key
        when :background_color
          render_background_color_field(object, form, key)
        when :start_date, :end_date
          render_date_field(object, form, key)
        when object.preference_type(key).to_sym == :boolean
          render_boolean_field(object, form, key)
        else
          render_default_field(object, form, key)
        end
      end

      def render_background_color_field(object, form, key)
        content_tag(:div, class: 'form-group', id: [object.class.to_s.parameterize, 'preference', key].join('-')) do
          form.label("preferred_#{key}", Spree.t(key), class: 'mb-2') +
            content_tag(:div, class: 'd-flex') do
              preference_field_for(form, "preferred_#{key}", type: object.preference_type(key), class: 'form-control mr-2') +
                content_tag(:div, '', class: 'color-preview',
                                      style: "background-color: #{object.preferred_background_color};
                                            height: 40px; width: 50px; margin-left: 10px;
                                            border-radius: 5px; border: 1px solid #ccc;"
                )
            end
        end
      end

      def render_boolean_field(object, form, key)
        content_tag(:div, preference_field_for(form, "preferred_#{key}", type: object.preference_type(key)) +
          form.label("preferred_#{key}", Spree.t(key), class: 'form-check-label'),
                    class: 'form-group form-check', id: [object.class.to_s.parameterize, 'preference', key].join('-')
        )
      end

      def render_date_field(object, form, key)
        content_tag(:div, class: 'form-group', id: "#{object.class.to_s.parameterize}-preference-#{key}") do
          form.label("preferred_#{key}", Spree.t(key), class: 'mb-2') +
            content_tag(:div, class: 'input-group datePickerTo', data: {
              wrap: 'true', 'alt-input': 'true', 'min-date': object.preferred_start_date, 'enable-time': 'true'
            }
            ) do
              form.text_field("preferred_#{key}", value: object.send("preferred_#{key}"), class: 'form-control shadow-none', 'data-input' => '')
            end
        end
      end

      def render_default_field(object, form, key)
        content_tag(:div, form.label("preferred_#{key}", Spree.t(key)) +
          preference_field_for(form, "preferred_#{key}", type: object.preference_type(key)),
                    class: 'form-group', id: [object.class.to_s.parameterize, 'preference', key].join('-')
        )
      end
    end
  end
end
