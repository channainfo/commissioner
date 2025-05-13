module SpreeCmCommissioner
  class TripQuery
    attr_reader :origin_id, :destination_id, :travel_date, :params

    def initialize(origin_id:, destination_id:, travel_date: DateTime.current, params: {})
      @origin_id = origin_id
      @destination_id = destination_id
      @travel_date = travel_date.to_datetime
      @travel_date = DateTime.current.to_datetime if travel_date.to_date == Date.current
      @params = params
    end

    def call
      return [] if travel_date.to_date < Date.current

      trip_type = params[:trip_type]
      sort_desc = params[:sort] == 'desc'

      return direct_trips.map { |trip| SpreeCmCommissioner::TripQueryResult.new([trip]) } if trip_type == 'direct'

      return connected_trips || [] if trip_type == 'connected'

      direct_results = direct_trips.map { |trip| SpreeCmCommissioner::TripQueryResult.new([trip]) }
      connected_results = connected_trips || []
      combined_results = direct_results + connected_results

      combined_results.sort_by do |result|
        time = result.trips.first.departure_time.strftime('%H%M%S').to_i
        sort_desc ? -time : time
      end
    end

    def direct_trips # rubocop:disable Metrics/AbcSize
      result = Spree::Variant
               .select('spree_variants.id AS variant_id,
                        vendors.id AS vendor_id,
                        vendors.name AS vendor_name,
                        routes.name AS route_name,
                        routes.short_name AS short_name,
                        boarding.stop_id AS origin_id,
                        drop_off.stop_id AS destination_id,
                        boarding.stop_name AS origin,
                        drop_off.stop_name AS destination,
                        trips.departure_time AS departure_time,
                        trips.duration AS duration,
                        trips.vehicle_id AS vehicle_id'
                      )
               .joins('INNER JOIN cm_trips AS trips ON trips.variant_id = spree_variants.id')
               .joins('INNER JOIN cm_trip_stops AS boarding ON boarding.trip_id = spree_variants.id AND boarding.stop_type = 0')
               .joins('INNER JOIN cm_trip_stops AS drop_off ON drop_off.trip_id = spree_variants.id AND drop_off.stop_type = 1')
               .joins('INNER JOIN spree_vendors AS vendors ON vendors.id = spree_variants.vendor_id')
               .joins('INNER JOIN spree_products AS routes ON routes.id = spree_variants.product_id')
      result = result.where(vendors: { id: params[:vendor_id] }) if params[:vendor_id].present?
      result = result.where('boarding.stop_id = ? AND drop_off.stop_id = ?', origin_id, destination_id)
                     .where('trips.departure_time > ? AND trips.departure_time <= ?',
                            Time.zone.parse(travel_date.to_s).utc.strftime('%H:%M:%S'),
                            Time.zone.parse(travel_date.end_of_day.to_s).utc.strftime('%H:%M:%S')
                           )
                     .order("trips.departure_time #{params[:sort] == 'desc' ? 'DESC' : 'ASC'}")

      result.map do |trip|
        trip_result_options = {
          trip_id: trip[:variant_id],
          vendor_id: trip[:vendor_id],
          vendor_name: trip[:vendor_name],
          route_name: trip[:route_name],
          short_name: trip[:short_name],
          detail: trip[:variant_id],
          origin_id: trip[:origin_id],
          origin: trip[:origin],
          destination_id: trip[:destination_id],
          destination: trip[:destination],
          vehicle_id: trip[:vehicle_id],
          departure_time: Time.zone.parse(trip[:departure_time].to_s),
          duration: trip[:duration]
        }
        SpreeCmCommissioner::TripResult.new(trip_result_options)
      end
    end

    def connected_trips # rubocop:disable Metrics/MethodLength
      result = SpreeCmCommissioner::TripConnection
               .joins('
                INNER JOIN spree_variants variant1 ON variant1.id = cm_trip_connections.from_trip_id
                INNER JOIN spree_variants variant2 ON variant2.id = cm_trip_connections.to_trip_id
                INNER JOIN spree_products AS routes1 ON routes1.id = variant1.product_id
                INNER JOIN spree_products AS routes2 ON routes2.id = variant2.product_id
                INNER JOIN cm_trips AS trip1 ON trip1.variant_id = cm_trip_connections.from_trip_id
                INNER JOIN cm_trips AS trip2 ON trip2.variant_id = cm_trip_connections.to_trip_id
                INNER JOIN cm_trip_stops trip1_origin ON trip1_origin.trip_id = variant1.id AND trip1_origin.stop_type = 0
                INNER JOIN cm_trip_stops trip2_origin ON trip2_origin.trip_id = variant2.id AND trip2_origin.stop_type = 0
                INNER JOIN cm_trip_stops trip2_destination ON trip2_destination.trip_id = variant2.id AND trip2_destination.stop_type = 1
                INNER JOIN spree_vendors AS vendor1 ON vendor1.id = variant1.vendor_id
                INNER JOIN spree_vendors AS vendor2 ON vendor2.id = variant2.vendor_id'
                     )
               .select('cm_trip_connections.id AS id,
                        trip1.variant_id AS trip1_id,
                        trip1.origin_id AS trip1_origin_id,
                        trip1.destination_id AS trip1_destination_id,
                        trip1.departure_time AS trip1_departure_time,
                        trip1.duration AS trip1_duration,
                        routes1.short_name AS route1_short_name,
                        routes1.name AS route1_name,
                        trip1.vehicle_id AS trip1_vehicle,
                        vendor1.name AS trip1_vendor_name,
                        trip2.variant_id AS trip2_id,
                        trip2.origin_id AS trip2_origin_id,
                        trip2.destination_id AS trip2_destination_id,
                        trip2.departure_time AS trip2_departure_time,
                        trip2.duration AS trip2_duration,
                        trip2.vehicle_id AS trip2_vehicle,
                        routes2.short_name AS route2_short_name,
                        routes2.name AS route2_name,
                        trip1_origin.stop_name AS trip1_origin,
                        trip2_origin.stop_name AS trip2_origin,
                        trip2_destination.stop_name AS trip2_destination,
                        vendor2.name AS trip2_vendor_name'
                      ).where('trip1_origin.stop_id = ? AND trip2_destination.stop_id = ?', origin_id, destination_id)
      result = result.where('vendor1.id = ? OR vendor2.id = ?', params[:vendor_id], params[:vendor_id]) if params[:vendor_id].present?
      result = result.where('trip1.departure_time > ? AND trip1.departure_time <= ?', Time.zone.parse(travel_date.to_s).utc.strftime('%H:%M:%S'),
                            Time.zone.parse(travel_date.end_of_day.to_s).utc.strftime('%H:%M:%S')
      )
                     .distinct
                     .order("trip1.departure_time #{params[:sort] == 'desc' ? 'DESC' : 'ASC'}")

      return [] if result.blank?

      build_trip_query_result(result)
    end

    private

    def build_trip_query_result(connections)
      connections.map do |trip|
        from_trip = {
          trip_id: trip[:trip1_id],
          origin_id: trip[:trip1_origin_id],
          destination_id: trip[:trip1_destination_id],
          departure_time: Time.zone.parse(trip[:trip1_departure_time].to_s),
          duration: trip[:trip1_duration],
          vendor_name: trip[:trip1_vendor_name],
          route_name: trip[:route1_name],
          short_name: trip[:route1_short_name],
          vehicle_id: trip[:trip1_vehicle],
          origin: trip[:trip1_origin],
          destination: trip[:trip2_origin]
        }
        to_trip = {
          trip_id: trip[:trip2_id],
          origin_id: trip[:trip2_origin_id],
          destination_id: trip[:trip2_destination_id],
          departure_time: Time.zone.parse(trip[:trip2_departure_time].to_s),
          duration: trip[:trip2_duration],
          vendor_name: trip[:trip2_vendor_name],
          route_name: trip[:route2_name],
          short_name: trip[:route2_short_name],
          vehicle_id: trip[:trip2_vehicle],
          origin: trip[:trip2_origin],
          destination: trip[:trip2_destination]
        }
        data = [SpreeCmCommissioner::TripResult.new(from_trip),
                SpreeCmCommissioner::TripResult.new(to_trip)
                ]
        SpreeCmCommissioner::TripQueryResult.new(data, connection_id: trip[:id])
      end
    end
  end
end
