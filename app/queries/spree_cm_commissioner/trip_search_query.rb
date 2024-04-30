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
      trips_info.map do |trip|
        trip_result_options = {
          trip_id: trip.trip_id,
          vendor_id: trip.vendor_id,
          vendor_name: trip.vendor_name,
          route_name: trip.route_name,
          short_name: trip.short_name,
          detail: trip.trip_id,
          origin_id: trip.origin_id,
          origin: trip.origin,
          destination_id: trip.destination_id,
          destination: trip.destination,
          total_sold: trip.total_sold,
          total_seats: trip.total_seats,
          vehicle_id: trip.vehicle_id,
          departure_time: trip.departure_time.strftime('%H:%M'),
          duration: trip.duration
        }
        SpreeCmCommissioner::TripResult.new(trip_result_options)
      end
    end

    def trips_info
      result = Spree::Variant.select('spree_variants.id as trip_id,
                              spree_vendors.id as vendor_id,
                              spree_vendors.name as vendor_name,
                              routes.name as route_name,
                              routes.short_name as short_name,
                              details.id as detail_id,
                              boarding.stop_id as origin_id,
                              drop_off.stop_id as destination_id,
                              details.departure_time as departure_time,
                              details.duration as duration,
                              boarding.stop_name as origin,
                              drop_off.stop_name as destination,
                              COALESCE(ts.total_sold, 0) as total_sold,
                              cm_vehicles.number_of_seats as total_seats,
                              cm_vehicles.id as vehicle_id
                            '
                                    )
                             .joins('INNER JOIN spree_products routes ON routes.id = spree_variants.product_id')
                             .joins('INNER JOIN cm_trips details on details.product_id = routes.id')
                             .joins('INNER JOIN cm_vehicles ON cm_vehicles.id = details.vehicle_id')
                             .joins("INNER JOIN cm_trip_stops boarding ON boarding.trip_id = details.id AND boarding.stop_type = '0'")
                             .joins("INNER JOIN cm_trip_stops drop_off ON drop_off.trip_id = details.id AND drop_off.stop_type = '1'")
                             .joins('INNER JOIN spree_vendors ON spree_vendors.id = spree_variants.vendor_id')
                             .joins("LEFT JOIN (#{total_sold.to_sql}) ts ON spree_variants.id = ts.trip_id")

      # TODO: migrat to new table: vehicle, orign and destination
      result = result.where(boarding: { stop_id: origin_id }, drop_off: { stop_id: destination_id })
      result = result.where(vendor_id: vendor_id) if vendor_id.present?
      result
    end

    def total_sold
      Spree::Variant.select('spree_variants.id as trip_id, SUM(spree_line_items.quantity) as total_sold')
                    .joins('INNER JOIN spree_line_items ON spree_line_items.variant_id = spree_variants.id')
                    .joins('INNER JOIN spree_orders ON spree_orders.id = spree_line_items.order_id')
                    .where(spree_orders: { state: 'complete' })
                    .where(spree_line_items: { date: date })
                    .group('spree_variants.id')
    end
  end
end
