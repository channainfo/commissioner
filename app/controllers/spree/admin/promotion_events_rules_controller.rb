# abstract class: list events for the whole year
module Spree
  module Admin
    class PromotionEventsRulesController < ResourceController
      belongs_to 'spree/promotion'

      helper_method :month_name, :year, :beginning_of_year, :end_of_year

      before_action :ensure_year, only: [:edit]

      def object_name
        'promotion_rule'
      end

      def ensure_year
        year = params[:year].to_i

        return if year.present? && year > 1970

        redirect_to url_for(year: Time.zone.today.year)
      end

      def year
        params[:year].to_i
      end

      def beginning_of_year
        Date.new(year, 1, 1).beginning_of_year
      end

      def end_of_year
        Date.new(year, 1, 1).end_of_year
      end

      def month_name(month)
        Date::MONTHNAMES[month]
      end

      # override
      def model_class
        Spree::PromotionRule
      end
    end
  end
end
