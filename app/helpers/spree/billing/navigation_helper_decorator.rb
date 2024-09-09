module Spree
  module Billing
    module NavigationHelperDecorator
      def billing_main_menu_tree(text, icon: nil, sub_menu: nil, url: '#')
        content_tag :li, class: 'sidebar-menu-item d-block w-100 text-muted' do
          main_menu_item(text, url: url, icon: icon) +
            render(partial: "spree/billing/shared/sub_menu/#{sub_menu}")
        end
      end

      def customer_per_page_dropdown
        per_page_default = Spree::Backend::Config.admin_orders_per_page
        per_page_options = %w[24 48 120 200 400 600]

        selected_option = params[:per_page].try(:to_i) || per_page_default

        select_tag(:per_page,
                   options_for_select(per_page_options, selected_option),
                   class: "w-auto form-control js-per-page-select per-page-selected-#{selected_option} custom-select custom-select-sm"
                  )
      end
    end
  end
end

Spree::Admin::NavigationHelper.prepend(Spree::Billing::NavigationHelperDecorator)
