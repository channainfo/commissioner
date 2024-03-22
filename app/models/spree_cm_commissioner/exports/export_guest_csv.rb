module SpreeCmCommissioner
  module Exports
    class ExportGuestCsv < Export
      preference :event_id, :integer
      after_create :export_csv

      def initialize(attributes = nil)
        super
        set_name
        set_file_name
        set_file_path
        set_export_type
      end

      def csv_name
        @csv_name ||= "guest-csv#{Time.current.to_i}"
      end

      def csv_file_path
        @csv_file_path ||= Rails.root.join('tmp', csv_file_name)
      end

      def csv_file_name
        @csv_file_name ||= "guests-data-#{Spree::Taxon.find(preferred_event_id).name.downcase.gsub(' ', '-')}-#{Time.current.to_i}.csv"
      end

      def construct_header
        ['Full Name', 'Date of Birth', 'Gender', 'Occupation', 'ID Card Type']
      end

      def construct_row(guest)
        [
          guest.full_name,
          guest.dob&.strftime('%d %b %Y'),
          guest.gender&.titleize,
          guest.other_occupation&.titleize || guest.occupation&.name,
          guest.id_card&.card_type&.titleize
        ]
      end

      def scope
        SpreeCmCommissioner::Guest.where(event_id: preferred_event_id)
      end

      private

      def set_name
        self.name = csv_name
      end

      def set_file_name
        self.file_name = csv_file_name
      end

      def set_file_path
        self.file_path = csv_file_path
      end

      def set_export_type
        self.export_type = ExportGuestCsv
      end
    end
  end
end
