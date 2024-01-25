module SpreeCmCommissioner
  module Admin
    module Tabs
      class OrderDefaultTabsBuilder
        include ::Spree::Core::Engine.routes.url_helpers

        def add_all
          ::Rails.application.config.spree_backend.tabs[:order].add(notification_tab)
        end

        def notification_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('notifications', -> (resource) { notifications_admin_order_path(resource) })
            .with_icon_key('send-check-fill.svg')
            .with_active_check
            .with_completed_check
            .with_data_hook('admin_order_tabs_notifications')
            .build
        end
      end
    end
  end
end
