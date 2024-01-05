module SpreeCmCommissioner
  module Admin
    module MainMenu
      class DefaultConfigurationBuilder
        include ::Spree::Core::Engine.routes.url_helpers

        def add_all
          ::Rails.application.config.spree_backend.main_menu.add(add_calendar_section)
          ::Rails.application.config.spree_backend.main_menu.add(add_organization_section)

          ::Rails.application.config.spree_backend.main_menu.add_to_section('content', add_customer_notifications_sub_tab)
          ::Rails.application.config.spree_backend.main_menu.add_to_section('settings', homepage_sub_tab)
          ::Rails.application.config.spree_backend.main_menu.add_to_section('settings', icons_sub_tab)
        end

        def add_customer_notifications_sub_tab
          ::Spree::Admin::MainMenu::ItemBuilder
            .new('customer_notifications', admin_customer_notifications_path)
            .with_admin_ability_check(SpreeCmCommissioner::CustomerNotification)
            .build
        end

        def add_calendar_section
          items = [
            ::Spree::Admin::MainMenu::ItemBuilder
              .new('orders', admin_calendars_orders_path)
              .build
          ]

          ::Spree::Admin::MainMenu::SectionBuilder
            .new('calendar', 'calendar4-event.svg')
            .with_items(items)
            .build
        end

        def add_organization_section
          items = [
            ::Spree::Admin::MainMenu::ItemBuilder
              .new('vendors', admin_vendors_path)
              .with_admin_ability_check(Spree::Vendor)
              .build
          ]

          ::Spree::Admin::MainMenu::SectionBuilder
            .new('organizations', 'building.svg')
            .with_items(items)
            .build
        end

        def homepage_sub_tab
          ::Spree::Admin::MainMenu::ItemBuilder
            .new('homepage', edit_admin_homepage_feed_path)
            .build
        end

        def icons_sub_tab
          ::Spree::Admin::MainMenu::ItemBuilder
            .new('icons', admin_vectors_icons_path)
            .build
        end
      end
    end
  end
end
