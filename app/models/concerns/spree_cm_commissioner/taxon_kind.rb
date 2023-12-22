module SpreeCmCommissioner
  module TaxonKind
    extend ActiveSupport::Concern

    included do
      enum kind: { category: 0, cms: 1, event: 2, occupation: 3 }
    end
  end
end
