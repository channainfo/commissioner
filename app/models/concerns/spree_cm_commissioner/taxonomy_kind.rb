module SpreeCmCommissioner
  module TaxonomyKind
    extend ActiveSupport::Concern

    KINDS = %i[transit cms category].freeze

    included do
      enum kind: KINDS if table_exists? && column_names.include?('kind')
    end
  end
end
