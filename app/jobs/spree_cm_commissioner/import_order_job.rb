module SpreeCmCommissioner
  class ImportOrderJob < ApplicationJob
    def perform(import_order_id, import_by_user_id, import_type)
      if import_type == 'new_order'
        SpreeCmCommissioner::Imports::CreateOrderService.new(
          import_order_id: import_order_id,
          import_by_user_id: import_by_user_id
        ).call
      else
        SpreeCmCommissioner::Imports::UpdateOrderService.new(
          import_order_id: import_order_id
        ).call
      end
    end
  end
end
