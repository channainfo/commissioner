module Spree
  module Admin
    class PromotionWeekendRulesController < PromotionEventsRulesController
      before_action :load_events, only: %i[edit]

      def remove_exception_date
        index = params['exception_date_index'].to_i
        @promotion_rule.preferred_exception_dates.delete_at(index) if index.present?

        flash[:success] = flash_message_for(@promotion_rule, :successfully_updated) if @promotion_rule.save

        # reload page
        respond_to do |format|
          format.js { render inline: 'location.reload();' } # rubocop:disable Rails/RenderInline
        end
      end

      def load_events
        @events = []

        (beginning_of_year..end_of_year).each do |date|
          if @promotion_rule.exception?(date)
            @events << SpreeCmCommissioner::CalendarEvent.new(
              from_date: date,
              to_date: date,
              title: 'Exception',
              options: { exception: true }
            )
          elsif @promotion_rule.date_eligible?(date)
            @events << SpreeCmCommissioner::CalendarEvent.new(
              from_date: date,
              to_date: date,
              title: 'Eligible Date',
              options: {}
            )
          end
        end
      end

      # override
      def permitted_resource_params
        preferred_exception_dates = @promotion_rule.preferred_exception_dates.presence || []
        preferred_exception_dates << params.require(:new_exception_date).permit(:start_date, :length, :title).to_json

        { :preferred_exception_dates => preferred_exception_dates }
      end

      # override
      def collection_url(_options = {})
        edit_admin_promotion_weekend_rule_path(@promotion_rule.promotion_id, @promotion_rule.id)
      end

      # override
      def model_class
        SpreeCmCommissioner::Promotion::Rules::Weekend
      end
    end
  end
end
