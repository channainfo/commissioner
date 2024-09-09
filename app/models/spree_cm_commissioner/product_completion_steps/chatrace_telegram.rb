module SpreeCmCommissioner
  module ProductCompletionSteps
    class ChatraceTelegram < ProductCompletionStep
      # eg. https://t.me/ThePlatformKHBot?start=bookmeplus
      preference :entry_point_link, :string

      # override
      def action_url_for(line_item)
        return nil if preferred_entry_point_link.blank?
        return nil unless line_item.guests.any?

        "#{preferred_entry_point_link}--#{line_item.guests[0].token}"
      end

      # consider completed when telegram_user_id is set to guest by bot
      # via update: /api/chatrace/guests
      def completed?(line_item)
        return false if preferred_entry_point_link.blank?
        return false unless line_item.guests.any?

        line_item.guests[0].preferred_telegram_user_id.present?
      end
    end
  end
end
