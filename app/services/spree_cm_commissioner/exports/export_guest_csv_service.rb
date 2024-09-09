module SpreeCmCommissioner
  module Exports
    class ExportGuestCsvService
      attr_reader :export_id

      def initialize(export_id)
        @export_id = export_id
      end

      def call
        update_export_status_when_start
        generate_csv_file
        update_export_status_when_finish(:done)
      rescue StandardError => e
        update_export_status_when_finish(:failed)
        raise e
      end

      def export
        @export ||= SpreeCmCommissioner::Exports::ExportGuestCsv.find(export_id)
      end

      def generate_csv_file
        CSV.open(export.file_path, 'w') do |csv|
          csv << export.construct_header

          export.scope.find_each do |resource|
            csv << export.construct_row(resource)
          end
        end

        attach_csv_file
      end

      def attach_csv_file
        export.exported_file.attach(io: File.open(export.file_path), filename: export.file_name)
      end

      def update_export_status_when_start
        export.update(status: :progress, started_at: Time.zone.now)
      end

      def update_export_status_when_finish(status)
        export.update(status: status, finished_at: Time.zone.now)
      end
    end
  end
end
