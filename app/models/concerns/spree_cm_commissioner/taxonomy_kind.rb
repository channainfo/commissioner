module SpreeCmCommissioner
  module TaxonomyKind
    extend ActiveSupport::Concern

    KINDS = %i[cms category transit].freeze

    included do
      enum kind: KINDS if table_exists? && column_names.include?('kind')
    end
  end
end
