module SpreeCmCommissioner
  module BibNumberConcern
    extend ActiveSupport::Concern

    included do
      after_update :generate_bib_number_job, if: :should_generate_bib_number?

      def generate_bib_number_job
        # Iterate over the filtered line items
        line_items_with_bib_number_prefix_and_kyc.each do |line_item|
          line_item.guests.where(bib_number: [nil, '']).find_each(&:generate_bib_number)
        end
      end

      private

      # Check if the state has changed to complete and at least one line item has a bib_number_prefix
      def should_generate_bib_number?
        state_changed_to_complete? && bib_number_prefix?
      end

      # Verify if any line item has a bib_number_prefix
      def bib_number_prefix?
        line_items_with_bib_number_prefix_and_kyc.any?
      end

      # Select line items that have kyc? and bib-number-prefix
      def line_items_with_bib_number_prefix_and_kyc
        line_items.includes(:guests).select do |line_item|
          line_item.kyc? && line_item.option_types.any? { |option_type| option_type.name == 'bib-number-prefix' }
        end
      end
    end
  end
end
