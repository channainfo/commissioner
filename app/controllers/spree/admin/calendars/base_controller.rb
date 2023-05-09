module Spree
  module Admin
    module Calendars
      class BaseController < Spree::Admin::ResourceController
        rescue_from Date::Error, with: :redirect_to_current_date

        def redirect_to_current_date
          redirect_to url_for(default_url_options)
        end

        def default_url_options
          { active_date: Time.zone.today }
        end

        # 2023-06-05
        def active_date
          @active_date ||= parse_date!(params[:active_date])
        end
      end
    end
  end
end
