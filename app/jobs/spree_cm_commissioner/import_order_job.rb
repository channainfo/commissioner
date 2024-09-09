module SpreeCmCommissioner
  class ImportOrderJob < ApplicationJob
    def perform(import_order_id, import_by_user_id, import_type)
      SpreeCmCommissioner::Imports::ImportOrderService.new(
        import_order_id: import_order_id,
        import_by_user_id: import_by_user_id,
        import_type: import_type
      ).call
    end
  end
end
