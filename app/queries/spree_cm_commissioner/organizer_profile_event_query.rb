module SpreeCmCommissioner
  class OrganizerProfileEventQuery
    attr_reader :vendor_id, :section, :start_from_date

    # user_id: user ID, vendor_id: vendor ID, section: 'upcoming' or 'previous'
    def initialize(vendor_id:, section:, start_from_date: nil)
      @vendor_id = vendor_id
      @section = section
      @start_from_date = start_from_date || Time.zone.now
    end

    def events
      taxons = Spree::Taxon.where(vendor_id: vendor_id)

      if section == 'upcoming'
        taxons.where('to_date >= ?', start_from_date)
              .order(from_date: :asc)
      else
        taxons.where('to_date < ?', start_from_date)
              .order(to_date: :desc)
      end
    end
  end
end
