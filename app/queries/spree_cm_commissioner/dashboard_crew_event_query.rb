module SpreeCmCommissioner
  class DashboardCrewEventQuery
    attr_reader :user_id, :section, :start_from_date

    # user_id:, section: 'incoming | previous'
    def initialize(user_id:, section:, start_from_date: nil)
      @user_id = user_id
      @section = section
      @start_from_date = start_from_date || Time.zone.today
    end

    def events
      taxons = Spree::Taxon.joins(:user_events).where(user_events: { user_id: user_id })

      if section == 'incoming'
        taxons.where('from_date >= ?', start_from_date)
              .order(from_date: :asc)
      else
        taxons.where('from_date < ?', start_from_date)
              .order(to_date: :desc)
      end
    end
  end
end
