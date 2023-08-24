module SpreeCmCommissioner
  module Telegram
    module BaseHelper
      def render_image
        return unless item.variant.images.any?

        image_tag main_app.url_for(item.variant.images.first.url(:small)), :class => 'mr-3'
      end

      def pretty_time(time)
        return '' if time.blank?

        [I18n.l(time.to_date, format: :long), time.strftime('%l:%M %p %Z')].join(' ')
      end
    end
  end
end
