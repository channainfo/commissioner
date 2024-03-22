module SpreeCmCommissioner
  class DownloadGuestCsv < BaseInteractor
    delegate :csv_file_path, :generate_guest_csv_job_id, to: :context

    def call
      case Sidekiq::Status.status(generate_guest_csv_job_id)
      when :complete
        context.csv_file_path = csv_file_path
      when :failed
        context.message = Spree.t('csv.csv_failed')
      when :queued
        context.message = Spree.t('csv.csv_queued')
      when :working
        context.message = Spree.t('csv.csv_progress')
      when :interrupted
        context.message = Spree.t('csv.csv_interrupted')
      else
        context.message = Spree.t('csv.csv_unknown_status')
      end
    end
  end
end
