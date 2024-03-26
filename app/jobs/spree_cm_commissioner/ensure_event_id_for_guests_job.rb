module SpreeCmCommissioner
  class EnsureEventIdForGuestsJob < ApplicationJob
    def perform
      SpreeCmCommissioner::Guest.complete.unassigned_event.find_each do |guest|
        guest.set_event_id
        guest.save!
      end
    end
  end
end
