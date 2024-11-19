# waiting_room_latest_system_metadata_puller:
#   cron: "*/30 * * * *" # Every 30 minute
#   class: "SpreeCmCommissioner::WaitingRoomLatestSystemMetadataPuller"
module SpreeCmCommissioner
  class WaitingRoomLatestSystemMetadataPullerJob < ApplicationJob
    queue_as :waiting_room

    def perform
      return if ENV['WAITING_ROOM_DISABLED'] == 'yes'

      SpreeCmCommissioner::WaitingRoomLatestSystemMetadataPuller.call
    end
  end
end
