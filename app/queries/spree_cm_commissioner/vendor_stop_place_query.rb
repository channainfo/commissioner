module SpreeCmCommissioner
  class VendorStopPlaceQuery
    attr_reader :query, :vendor_id, :stop_type, :reference_stop_id

    def initialize(query:, vendor_id:, stop_type: :boarding, reference_stop_id: nil)
      @query = query.to_s.strip
      @vendor_id = vendor_id
      @stop_type = stop_type
      @reference_stop_id = reference_stop_id
    end

    def call
      results = vendor_stops
      return [] if results.empty?

      places = results.includes(:stop).map(&:stop).compact.uniq

      format_places(places)
    end

    private

    def vendor_stops
      scope = base_scope
      return scope if query.blank?

      scope = scope.where.not(stop_id: reference_stop_id) if reference_stop_id.present?
      scope.where('cm_places.name ILIKE ?', "%#{query}%")
    end

    def base_scope
      SpreeCmCommissioner::VendorStop
        .joins(:stop)
        .where(vendor_id: vendor_id)
        .where(stop_type: stop_type)
        .order(trip_count: :desc)
        .where.not(trip_count: 0)
    end

    def format_places(places)
      places
        .sort_by { |p| [-p.depth, -p.lft] }
        .filter_map do |place|
          next if place.depth.zero?

          {
            id: place.id,
            parent_id: place.parent_id,
            name: place.self_and_ancestors.map(&:name).reverse.join(', ')
          }
        end
    end
  end
end
