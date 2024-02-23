module SpreeCmCommissioner
  class DashboardCrewEventQuery
    attr_reader :user_id, :section, :start_from_date

    # user_id:, section: 'incoming | previous'
    def initialize(user_id:, section:, start_from_date: nil)
      @user_id = user_id
      @section = section
      @start_from_date = start_from_date || Time.zone.today
    end

    def call
      events
    end

    def events
      select_fields = [
        'spree_taxons.id AS taxon_id',
        'spree_taxons.name',
        'spree_taxons.permalink',
        'spree_taxons.from_date',
        'spree_taxons.to_date',
        'spree_taxons.updated_at',
        'ARRAY_AGG(spree_products_taxons.id) AS product_taxon_ids'
      ]

      taxons = Spree::Taxon
               .select(select_fields)
               .joins('INNER JOIN spree_taxons section ON section.parent_id = spree_taxons.id')
               .joins('INNER JOIN spree_products_taxons ON spree_products_taxons.taxon_id = section.id')
               .joins('INNER JOIN cm_user_taxons ON spree_taxons.id = cm_user_taxons.taxon_id')
               .where(cm_user_taxons: { user_id: user_id, type: 'SpreeCmCommissioner::UserEvent' })
               .group('spree_taxons.id')

      if section == 'incoming'
        taxons.where('spree_taxons.from_date >= ?', start_from_date)
              .order(from_date: :asc)
      else
        taxons.where('spree_taxons.from_date < ?', start_from_date)
              .order(to_date: :desc)
      end
    end
  end
end
