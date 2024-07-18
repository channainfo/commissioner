module SpreeCmCommissioner
  class BibNumberGenerator < BaseInteractor
    delegate :taxon_id, to: :context

    def call
      guests_with_bib_number_prefix.each(&:generate_bib_number)
    end

    private

    def taxon
      @taxon ||= Spree::Taxon.find(taxon_id)
    end

    def guests_with_bib_number_prefix
      taxon.guests.includes(:line_item, line_item: :option_types).where(bib_number: [nil, '']).select do |guest|
        guest.line_item.option_types.any? { |option_type| option_type.name == 'bib-number-prefix' }
      end
    end
  end
end
