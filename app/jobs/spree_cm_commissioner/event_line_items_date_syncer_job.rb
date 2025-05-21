module SpreeCmCommissioner
  class EventLineItemsDateSyncerJob < ApplicationJob
    def perform(event_id)
      event = Spree::Taxon.event.find(event_id)
      SpreeCmCommissioner::EventLineItemsDateSyncer.call(event: event)
    end
  end
end
