module Spree
  module Admin
    class PromotionCustomDatesRulesController < PromotionEventsRulesController
      before_action :load_events, only: %i[edit]

      def remove_custom_date
        index = params['custom_date_index'].to_i
        @promotion_rule.preferred_custom_dates.delete_at(index) if index.present?

        flash[:success] = flash_message_for(@promotion_rule, :successfully_updated) if @promotion_rule.save

        # reload page
        respond_to do |format|
          format.js { render inline: 'location.reload();' } # rubocop:disable Rails/RenderInline
        end
      end

      def load_events
        @events = []

        @promotion_rule.preferred_custom_dates&.each do |json|
          custom_date = JSON.parse(json)

          start_date = custom_date['start_date']&.to_date
          length = custom_date['length']&.to_i
          title = custom_date['title']

          next unless start_date.present? && length.present?

          end_date = start_date + length.days - 1
          @events << SpreeCmCommissioner::CalendarEvent.new(
            from_date: start_date,
            to_date: end_date,
            title: title,
            options: {}
          )
        end
      end

      # override
      def permitted_resource_params
        preferred_custom_dates = @promotion_rule.preferred_custom_dates.presence || []
        preferred_custom_dates << params.require(:new_custom_date).permit(:start_date, :length, :title).to_json

        { :preferred_custom_dates => preferred_custom_dates }
      end

      # override
      def collection_url(_options = {})
        edit_admin_promotion_custom_dates_rule_path(@promotion_rule.promotion_id, @promotion_rule.id)
      end

      # override
      def model_class
        SpreeCmCommissioner::Promotion::Rules::CustomDates
      end
    end
  end
end
