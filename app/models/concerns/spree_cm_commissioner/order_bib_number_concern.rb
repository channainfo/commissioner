module SpreeCmCommissioner
  module OrderBibNumberConcern
    extend ActiveSupport::Concern

    included do
      after_update :generate_bib_number, if: :state_changed_to_complete?

      def generate_bib_number
        line_items.with_bib_prefix.find_each do |line_item|
          line_item.guests.none_bib.find_each(&:generate_bib!)
        end
      end
    end
  end
end
