module SpreeCmCommissioner
  module Stock
    class StockMovementCreator < BaseInteractor
      delegate :variant_id, :stock_location_id, :current_store, :stock_movement_params, to: :context

      def call
        variant = current_store.variants.find(variant_id)

        return context.fail!(message: Spree.t(:doesnt_track_inventory)) unless variant.track_inventory?

        stock_location = Spree::StockLocation.find(stock_location_id)
        stock_movement = stock_location.stock_movements.build(stock_movement_params)
        stock_movement.stock_item = stock_location.set_up_stock_item(variant)

        if stock_movement.save
          SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob.perform_later(variant_id: variant.id, quantity: stock_movement.quantity)
          context.stock_movement = stock_movement
        else
          context.fail!(message: stock_movement.errors.full_messages.join(', '))
        end
      end
    end
  end
end
