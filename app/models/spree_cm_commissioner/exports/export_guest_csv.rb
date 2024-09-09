module SpreeCmCommissioner
  module Exports
    class ExportGuestCsv < Export
      preference :event_id, :integer
      after_create :export_csv

      def construct_header
        SpreeCmCommissioner::Guest.column_names.map(&:titleize)
      end

      def construct_row(guest)
        guest.attributes.map do |key, value|
          case key
          when 'dob'
            value&.strftime('%d %b %Y')
          when 'event_id'
            guest.event&.name
          when 'nationality_id'
            guest.nationality&.name
          when 'occupation_id'
            guest.occupation&.name
          else
            value
          end
        end
      end

      def scope
        SpreeCmCommissioner::Guest.where(event_id: preferred_event_id)
      end
    end
  end
end
