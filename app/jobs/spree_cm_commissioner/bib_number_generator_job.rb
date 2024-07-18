module SpreeCmCommissioner
  class BibNumberGeneratorJob < ApplicationJob
    def perform(taxon_id)
      SpreeCmCommissioner::BibNumberGenerator.call(taxon_id: taxon_id)
    end
  end
end
