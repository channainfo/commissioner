module SpreeCmCommissioner
  class OrganizerProfileEventQuery
    attr_reader :vendor_identifier, :section, :start_from_date

    # vendor_identifier can be either vendor_id or slug, section: 'upcoming', 'previous' or 'all'
    def initialize(vendor_identifier:, section:, start_from_date: nil)
      @vendor_identifier = vendor_identifier
      @section = section
      @start_from_date = start_from_date || Time.zone.now
    end

    def events
      vendor = find_vendor(vendor_identifier)

      taxons = Spree::Taxon.where(vendor_id: vendor.id)

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

    private

    def find_vendor(vendor_identifier)
      if vendor_identifier.is_a?(Integer) || vendor_identifier.to_s.match?(/\A\d+\z/)
        Spree::Vendor.find_by(id: vendor_identifier)
      else
        Spree::Vendor.find_by(slug: vendor_identifier)
      end
    end
  end
end
