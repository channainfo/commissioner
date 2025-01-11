module SpreeCmCommissioner
  class ExportCsvJob < ApplicationUniqueJob
    def perform(id)
      Exports::ExportGuestCsvService.new(id).call
    end
  end
end
