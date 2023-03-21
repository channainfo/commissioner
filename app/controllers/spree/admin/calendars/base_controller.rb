module Spree
  module Admin
    module Calendars
      class BaseController < Spree::Admin::ResourceController
        before_action :load_active_date

        rescue_from Date::Error, with: :redirect_to_current_date

        def redirect_to_current_date
          redirect_to url_for(default_url_options)
        end

        def default_url_options
          { active_date: Time.zone.today }
        end

        def load_active_date
          active_date
        end

        # 2023-06-05
        def active_date
          @active_date ||= Date.strptime(params[:active_date].to_s, '%Y-%m-%d')
        end
      end
    end
  end
end
