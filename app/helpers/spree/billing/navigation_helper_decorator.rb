module Spree
  module Billing
    module NavigationHelperDecorator
      def billing_main_menu_tree(text, icon: nil, sub_menu: nil, url: '#')
        content_tag :li, class: 'sidebar-menu-item d-block w-100 text-muted' do
          main_menu_item(text, url: url, icon: icon) +
            render(partial: "spree/billing/shared/sub_menu/#{sub_menu}")
        end
      end

      def vendor_tabs
        Rails.application.config.spree_backend.tabs[:vendor]
      end

      def order_event_button(order, event)
        label = Spree.t(event, scope: 'admin.order.events', default: Spree.t(event))
        button_link_to(
          label.capitalize,
          [event.to_sym, :admin, order],
          method: :put,
          icon: "#{event}.svg",
          data: { confirm: Spree.t(:order_sure_want_to, event: label) },
          class: 'btn-light'
        )
      end
    end
  end
end

Spree::Admin::NavigationHelper.prepend(Spree::Billing::NavigationHelperDecorator)
