module Exports
  class ExportGuestCsvService
    attr_reader :export

    def call(id)
      load_export(id)
      update_export_status_to_progress
      generate_csv_file
    end

    private

    def load_export(id)
      @export = SpreeCmCommissioner::Exports::ExportGuestCsv.find(id)
    end

    def update_export_status_to_progress
      export.update(status: :progress, started_at: Time.zone.now)
    end

    def generate_csv_file
      CSV.open(export.file_path, 'w') do |csv|
        csv << export.construct_header

        export.scope.find_each do |resource|
          csv << export.construct_row(resource)
        end
      end

      if export.exported_file.attach(io: File.open(export.file_path), filename: export.file_name)
        export.update(status: :done)
      else
        export.update(status: :failed)
      end
    end
  end
end
