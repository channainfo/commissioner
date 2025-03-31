module SpreeCmCommissioner
  class TaxonBlazerQuery < SpreeCmCommissioner::Base
    belongs_to :taxon, class_name: 'Spree::Taxon'
    belongs_to :blazer_query, class_name: 'Blazer::Query'

    validates :taxon_id, uniqueness: { scope: :blazer_query_id, message: I18n.t('event_blazer_queries.fail') }
  end
end
