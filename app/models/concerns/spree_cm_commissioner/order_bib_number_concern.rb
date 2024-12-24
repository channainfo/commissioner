module SpreeCmCommissioner
  module OrderBibNumberConcern
    extend ActiveSupport::Concern

    included do
      after_update :generate_guests_and_bib_numbers, if: :state_changed_to_complete?

      def generate_bib_number!
        transaction do
          line_items.with_bib_prefix.find_each do |line_item|
            line_item.guests.none_bib.find_each(&:generate_bib!)
          end
        end
      end

      private

      def generate_guests_and_bib_numbers
        generate_remaining_guests
        generate_bib_number_aysnc
      end

      def generate_remaining_guests
        line_items.find_each(&:generate_remaining_guests)
      end

      def generate_bib_number_aysnc
        SpreeCmCommissioner::OrderCompleteBibGeneratorJob.perform_later(id)
      end
    end
  end
end
