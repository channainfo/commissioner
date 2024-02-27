module SpreeCmCommissioner
  class TripSearchQuery
    attr_reader :origin_id, :destination_id, :vendor_id, :date

    def initialize(origin_id:, destination_id:, date:, vendor_id: nil)
      @origin_id = origin_id
      @destination_id = destination_id
      @vendor_id = vendor_id
      @date = date
    end

    def call
      trips_info.group_by(&:trip_id).map do |_trip_id, trips|
        trip_result_options = {
          trip_id: trips.first.trip_id,
          vendor_id: trips.first.vendor_id,
          vendor_name: trips.first.vendor_name,
          route_name: trips.first.route_name,
          origin_id: trips.first.origin_id,
          origin: trips.first.origin,
          destination_id: trips.first.destination_id,
          destination: trips.first.destination,
          total_sold: trips.first.total_sold,
          total_seats: trips.first.total_seats,
          vehicle_id: trips.first.vehicle_id
        }
        trips.each do |trip|
          trip_result_options[trip.attr_type] = trip['option_value']
        end
        SpreeCmCommissioner::TripResult.new(trip_result_options)
      end
    end

    def trips_info
      result = Spree::Variant.select('spree_variants.id as trip_id,
                              spree_vendors.id as vendor_id,
                              spree_vendors.name as vendor_name,
                              routes.name as route_name,
                              routes.origin_id as origin_id,
                              origin.name as origin,
                              routes.destination_id as destination_id,
                              destination.name as destination,
                              spree_option_values.name as option_value,
                              spree_option_types.attr_type as attr_type,
                              COALESCE(ts.total_sold, 0) as total_sold,
                              cm_vehicles.number_of_seats as total_seats,
                              cm_vehicles.id as vehicle_id
                            '
                                    )
                             .joins('INNER JOIN spree_products routes ON routes.id = spree_variants.product_id')
                             .joins('INNER JOIN spree_option_value_variants ON spree_option_value_variants.variant_id = spree_variants.id')
                             .joins('INNER JOIN spree_option_values ON spree_option_values.id = spree_option_value_variants.option_value_id')
                             .joins('INNER JOIN spree_option_types ON spree_option_types.id = spree_option_values.option_type_id')
                             .joins('INNER JOIN cm_vehicles ON cm_vehicles.id = routes.vehicle_id')
                             .joins('INNER JOIN spree_vendors ON spree_vendors.id = spree_variants.vendor_id')
                             .joins('INNER JOIN spree_taxons origin on origin.id = routes.origin_id')
                             .joins('INNER JOIN spree_taxons destination on destination.id = routes.destination_id')
                             .joins("LEFT JOIN (#{total_sold_sql}) ts ON spree_variants.id = ts.trip_id")

      # TODO: migrat to variant attr_type orign and destination
      result = result.where(routes: { origin_id: origin_id, destination_id: destination_id })
      result = result.where(vendor_id: vendor_id) if vendor_id.present?
      result
    end

    def total_sold_sql
      Spree::Variant.select('spree_variants.id as trip_id, SUM(spree_line_items.quantity) as total_sold')
                    .joins('INNER JOIN spree_line_items ON spree_line_items.variant_id = spree_variants.id')
                    .where(spree_line_items: { date: date })
                    .group('spree_variants.id').to_sql
    end
  end
end
