module SpreeCmCommissioner
  module Admin
    module Actions
      class OrderDefaultActionsBuilder
        def add_all
          ::Rails.application.config.spree_backend.actions[:order].add(print_action)
        end

        def print_action
          ::Spree::Admin::Actions::ActionBuilder
            .new('print', -> (order) { "/o/#{order.qr_data}" })
            .with_icon_key('printer.svg')
            .with_target(:_blank)
            .build
        end
      end
    end
  end
end
