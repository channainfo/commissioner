module SpreeCmCommissioner
  module Admin
    module Tabs
      class VendorDefaultTabsBuilder
        include ::Spree::Core::Engine.routes.url_helpers

        def initialize
          ::Rails.application.config.spree_backend.tabs[:vendor] ||= ::Spree::Admin::Tabs::Root.new
        end

        def add_all
          ::Rails.application.config.spree_backend.tabs[:vendor].add(details_tab)
          ::Rails.application.config.spree_backend.tabs[:vendor].add(photos_tab)
          ::Rails.application.config.spree_backend.tabs[:vendor].add(vendor_option_types_tab)
          ::Rails.application.config.spree_backend.tabs[:vendor].add(nearby_places_tab)
          ::Rails.application.config.spree_backend.tabs[:vendor].add(service_calendars_tab)
          ::Rails.application.config.spree_backend.tabs[:vendor].add(telegram_tab)
        end

        def details_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('details', -> (resource) { edit_admin_vendor_path(resource) })
            .with_icon_key('edit.svg')
            .with_active_check
            .with_admin_ability_check(::Spree::Vendor)
            .build
        end

        def photos_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('photos', -> (resource) { admin_vendor_vendor_photos_path(resource) })
            .with_icon_key('images.svg')
            .with_active_check
            .with_admin_ability_check(::SpreeCmCommissioner::VendorPhoto)
            .build
        end

        def vendor_option_types_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('vendor_option_types', -> (resource) { admin_vendor_vendor_kind_option_types_path(resource) })
            .with_icon_key('extensions.svg')
            .with_active_check
            .with_admin_ability_check(::SpreeCmCommissioner::VendorOptionType)
            .build
        end

        def nearby_places_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('nearby_places', -> (resource) { admin_vendor_nearby_places_path(resource) })
            .with_icon_key('map.svg')
            .with_active_check
            .with_admin_ability_check(::SpreeCmCommissioner::VendorOptionType)
            .build
        end

        def service_calendars_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('service_calendars', -> (resource) { admin_vendor_vendor_service_calendars_path(resource) })
            .with_icon_key('calendar2-week.svg')
            .with_active_check
            .with_admin_ability_check(::SpreeCmCommissioner::ServiceCalendar)
            .build
        end

        def telegram_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('telegram', -> (resource) { admin_vendor_vendor_authorized_users_path(resource) })
            .with_icon_key('telegram.svg')
            .with_active_check
            .with_admin_ability_check(::Spree::Vendor)
            .build
        end
      end
    end
  end
end
