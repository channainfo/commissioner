module SpreeCmCommissioner
  class ExportCsvJob < ApplicationJob
    def perform(id)
      Exports::ExportGuestCsvService.new(id).call
    end
  end
end
