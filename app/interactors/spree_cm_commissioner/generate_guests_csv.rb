module SpreeCmCommissioner
  class GenerateGuestsCsv < BaseInteractor
    delegate :guest_ids, :csv_file_path, to: :context

    def call
      generate_guests_csv
    end

    private

    def generate_guests_csv
      context.generate_guests_csv_job_id = SpreeCmCommissioner::GenerateGuestsCsvJob.perform_async(guest_ids, csv_file_path)
    end
  end
end
