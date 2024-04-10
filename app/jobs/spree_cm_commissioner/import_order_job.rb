module SpreeCmCommissioner
  class ImportOrderJob < ApplicationJob
    def perform(import_order_id, user, orders)
      SpreeCmCommissioner::Imports::ImportOrderService.new(
        import_order_id: import_order_id,
        import_by: user,
        orders: orders
      ).call
    end
  end
end
