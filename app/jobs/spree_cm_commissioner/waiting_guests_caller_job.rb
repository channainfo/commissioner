# waiting_guests_caller:
#   cron: "*/1 * * * *" # Every minute
#   class: "SpreeCmCommissioner::WaitingGuestsCallerJob"
module SpreeCmCommissioner
  class WaitingGuestsCallerJob < ApplicationJob
    queue_as :waiting_room

    def perform
      return if ENV['WAITING_ROOM_DISABLED'] == 'yes'

      SpreeCmCommissioner::WaitingGuestsCaller.call
    end
  end
end
