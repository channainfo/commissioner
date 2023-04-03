module Spree
  module Admin
    module BaseControllerDecorator
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
