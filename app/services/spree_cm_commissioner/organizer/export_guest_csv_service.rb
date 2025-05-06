module SpreeCmCommissioner
  module Organizer
    class ExportGuestCsvService
      attr_reader :event_id, :columns

      def initialize(event_id, columns)
        @event_id = event_id
        @columns = columns
      end

      def call
        CSV.generate(headers: true) do |csv|
          csv << headers
          guests_with_associations.each { |guest| csv << build_row(guest) }
        end
      end

      private

      def headers
        columns.map(&:humanize).uniq
      end

      def build_row(guest)
        columns.map { |column| fetch_value(guest, column) }
      end

      def fetch_value(guest, column)
        if guest_field?(column)
          fetch_guest_value(guest, column)
        elsif option_type_field?(column)
          fetch_option_value(guest, column)
        else
          ''
        end
      end

      def guest_field?(column)
        SpreeCmCommissioner::KycBitwise::ORDERED_BIT_FIELDS.include?(column.to_sym)
      end

      def option_type_field?(column)
        Spree::OptionType.exists?(name: column)
      end

      def fetch_guest_value(guest, column)
        column_mappings(guest)[column] || ''
      end

      def fetch_option_value(guest, option_type_name)
        return guest.formatted_bib_number if option_type_name == 'bib-prefix'

        guest.line_item&.variant&.find_option_value_name_for(option_type_name: option_type_name)
      end

      def column_mappings(guest)
        {
          'guest_name' => "#{guest.first_name} #{guest.last_name}".strip,
          'guest_gender' => guest.gender,
          'guest_phone_number' => guest.phone_number,
          'guest_dob' => guest.dob.to_s,
          'guest_occupation' => guest.occupation&.name || guest.other_occupation,
          'guest_nationality' => guest.nationality&.name,
          'guest_age' => guest.age.to_s,
          'guest_emergency_contact' => guest.emergency_contact,
          'guest_organization' => guest.other_organization,
          'guest_social_contact' => guest.social_contact,
          'guest_address' => guest.address,
          'guest_expectation' => guest.expectation,
          'entry_type' => guest.entry_type,
          'guest_id_card' => guest_id_card(guest)
        }
      end

      def guest_id_card(guest)
        "#{guest.id_card&.front_image&.original_url}\n#{guest.id_card&.back_image&.original_url}"
      end

      def guests_with_associations
        event.guests.includes(
          :occupation,
          :nationality,
          :id_card,
          line_item: { variant: { option_values: :option_type } }
        )
      end

      def event
        @event ||= Spree::Taxon.find(@event_id)
      end
    end
  end
end
