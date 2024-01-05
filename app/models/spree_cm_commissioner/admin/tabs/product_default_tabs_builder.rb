module SpreeCmCommissioner
  module Admin
    module Tabs
      class ProductDefaultTabsBuilder
        include ::Spree::Core::Engine.routes.url_helpers

        def add_all
          ::Rails.application.config.spree_backend.tabs[:product].add(kyc_fields_tab)
          ::Rails.application.config.spree_backend.tabs[:product].add(master_variant_tab)
        end

        def kyc_fields_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('kyc_field', -> (resource) { edit_kyc_admin_product_path(resource) })
            .with_icon_key('card-heading.svg')
            .with_active_check
            .with_admin_ability_check(::Spree::Product)
            .build
        end

        def master_variant_tab
          ::Spree::Admin::Tabs::TabBuilder
            .new('master_variant', -> (resource) { admin_product_master_variant_index_path(resource) })
            .with_icon_key('adjust.svg')
            .with_active_check
            .with_availability_check(-> (ability, resource) { ability.can?(:admin, Spree::Variant) && !resource.deleted? })
            .build
        end
      end
    end
  end
end
