module SpreeCmCommissioner
  class DashboardCrewEventQuery
    attr_reader :user_id, :section

    # user_id:, section: 'incoming | previous'
    def initialize(user_id:, section:)
      @user_id = user_id
      @section = section
    end

    def call
      events
    end

    def events
      taxons = Spree::Taxon.select('spree_taxons.id AS taxon_id, spree_taxons.name, spree_taxons.permalink, spree_taxons.from_date, spree_taxons.to_date, spree_taxons.updated_at') # rubocop:disable Layout/LineLength
                           .joins('INNER JOIN cm_user_taxons ON spree_taxons.id = cm_user_taxons.taxon_id')
                           .where(cm_user_taxons: { user_id: user_id, type: 'SpreeCmCommissioner::UserEvent' })

      if section == 'incoming'
        taxons = taxons.where('spree_taxons.from_date >= ?', Time.zone.now)
        taxons = taxons.order(from_date: :asc)
      else
        taxons = taxons.where('spree_taxons.from_date < ?', Time.zone.now)
        taxons = taxons.order(to_date: :desc)
      end

      taxons
    end
  end
end
