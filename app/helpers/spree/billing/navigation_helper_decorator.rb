module Spree
  module Billing
    module NavigationHelperDecorator
      def billing_main_menu_tree(text, icon: nil, sub_menu: nil, url: '#')
        content_tag :li, class: 'sidebar-menu-item d-block w-100 text-muted' do
          main_menu_item(text, url: url, icon: icon) +
            render(partial: "spree/billing/shared/sub_menu/#{sub_menu}")
        end
      end
    end
  end
end

Spree::Admin::NavigationHelper.prepend(Spree::Billing::NavigationHelperDecorator)
