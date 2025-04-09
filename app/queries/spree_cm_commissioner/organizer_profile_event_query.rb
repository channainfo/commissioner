module SpreeCmCommissioner
  class OrganizerProfileEventQuery
    attr_reader :vendor_id, :section, :start_from_date

    # user_id: user ID, vendor_id: vendor ID, section: 'upcoming', 'previous' or 'all'
    def initialize(vendor_id:, section:, start_from_date: nil)
      @vendor_id = vendor_id
      @section = section
      @start_from_date = start_from_date || Time.zone.now
    end

    def events
      taxons = Spree::Taxon.includes(:vendor).where(vendor_id: vendor_id, depth: 1)

      case section
      when 'upcoming'
        taxons.where('to_date >= ?', start_from_date)
              .order(from_date: :asc)
      when 'previous'
        taxons.where('to_date < ?', start_from_date)
              .order(to_date: :desc)
      else
        taxons.order(from_date: :asc)
      end
    end
  end
end
