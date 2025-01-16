module Spree
  module Admin
    module BaseControllerDecorator
      def self.prepended(base)
        base.before_action :redirect_to_billing, if: -> { Spree::Store.default.code.include?('billing') }
      end

      # override
      # Default behavior is to return default store based on current URL.
      # Our admin URL is not store URL, so we return default store instead.
      def current_store
        @current_store ||= Rails.cache.fetch("current_store_#{request.host}", expires_in: 1.hour) do
          Spree::Store.where('url = ? OR url LIKE ?', request.host, "%#{request.host}%").first || Spree::Store.default
        end
      end

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

      # POST
      def invalidate_api_caches
        if params[:model].present?
          api_patterns_map = {
            'SpreeCmCommissioner::HomepageSection' => '/api/v2/storefront/homepage/*',
            'SpreeCmCommissioner::HomepageBackground' => '/api/v2/storefront/homepage/*',
            'Spree::Menu' => '/api/v2/storefront/menus*'
          }

          api_patterns = api_patterns_map[params[:model]]

          if api_patterns.is_a?(Array)
            api_patterns.each { |pattern| SpreeCmCommissioner::InvalidateCacheRequestJob.perform_later(pattern) }
          elsif api_patterns.is_a?(String)
            SpreeCmCommissioner::InvalidateCacheRequestJob.perform_later(api_patterns)
          end
        elsif params[:api_pattern].present?
          SpreeCmCommissioner::InvalidateCacheRequestJob.perform_later(params[:api_pattern])
        end

        redirect_back fallback_location: admin_root_path
      end

      private

      def redirect_to_billing
        return if request.path.include?('/billing')

        redirect_to billing_root_url unless spree_current_user.super_admin?
      end
    end
  end
end

Spree::Admin::BaseController.prepend(Spree::Admin::BaseControllerDecorator)
