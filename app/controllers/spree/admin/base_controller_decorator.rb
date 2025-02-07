module Spree
  module Admin
    module BaseControllerDecorator
      # even db in read only mode, authorizor still need to run Warden callbacks which will write to db
      # this include update tracked fields such as sign_in_count, last_sign_in_at, etc.
      def authorize!(*args)
        ActiveRecord::Base.connected_to(role: :writing) do
          super
        end
      end

      # override: even in view actions, head.html.erb still need admin_oauth_token which may create new token.
      def admin_oauth_token
        ActiveRecord::Base.connected_to(role: :writing) do
          super
        end
      end

      # 2023-07-31
      def parse_date!(date, format: nil)
        Date.strptime(date.to_s, format || '%Y-%m-%d')
      end

      def parse_date(date, format: nil)
        parse_date!(date, format)
      rescue Date::Error
        nil
      end
    end
  end
end

Spree::Admin::BaseController.prepend(Spree::Admin::BaseControllerDecorator)
