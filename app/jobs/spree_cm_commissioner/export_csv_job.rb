module SpreeCmCommissioner
  class ExportCsvJob
    include Sidekiq::Job

    sidekiq_options retry: 0

    def perform(id)
      ::Exports::ExportGuestCsvService.new.call(id)
    end
  end
end
