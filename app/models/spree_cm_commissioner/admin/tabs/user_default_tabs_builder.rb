module SpreeCmCommissioner
  module Admin
    module Tabs
      class UserDefaultTabsBuilder
        include ::Spree::Core::Engine.routes.url_helpers

        def add_all
          ::Rails.application.config.spree_backend.tabs[:user].add(device_tokens)
          ::Rails.application.config.spree_backend.tabs[:user].add(user_identity_providers)
        end

        def device_tokens
          ::Spree::Admin::Tabs::TabBuilder
            .new('device_tokens', -> (resource) { admin_user_device_tokens_path(resource) })
            .with_icon_key('key.svg')
            .with_active_check
            .build
        end

        def user_identity_providers
          ::Spree::Admin::Tabs::TabBuilder
            .new('user_identity_providers', -> (resource) { admin_user_user_identity_providers_path(resource) })
            .with_icon_key('telegram.svg')
            .with_active_check
            .build
        end
      end
    end
  end
end
