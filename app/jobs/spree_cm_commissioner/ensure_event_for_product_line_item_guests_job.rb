# Job to add set initial event_id to existing product, line_item, guest that miss the event_id.
module SpreeCmCommissioner
  class EnsureEventForProductLineItemGuestsJob < ApplicationJob
    def perform
      Spree::Taxon.event.includes(:children_products).find_each do |event|
        event.children_products.where('event_id IS NULL OR event_id != ?', event.id).find_each do |product|
          product.update_columns(event_id: event.id) # rubocop:disable Rails/SkipsModelValidations
          ::SpreeCmCommissioner::ProductEventIdToChildrenSyncerJob.perform_later(product.id)
        end
      end
    end
  end
end
