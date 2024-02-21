module SpreeCmCommissioner
  class TransitRouteQuery
    attr_reader :origin_id, :destination_id, :vendor_id, :date

    def initialize(origin_id:, destination_id:, date:, vendor_id: nil)
      @origin_id = origin_id
      @destination_id = destination_id
      @vendor_id = vendor_id
      @date = date
    end

    def call
      transit_trip_blueprint = Struct.new(:trip_id, :vendor_id, :vendor_name,
                                          :route_name, :origin, :destination,
                                          :option_values, :total_sold, :total_seats, :remaining_seats
      )
      result = trips_info
      trip_ids = result.pluck(:trip_id)
      variants = Spree::Variant.where(id: trip_ids).includes(:option_values).index_by(&:id)
      result.map do |r|
        variant = variants[r.trip_id]
        trip_instance = transit_trip_blueprint.new(r['trip_id'], r['vendor_id'], r['vendor_name'],
                                                   r['route_name'], r['origin'], r['destination'],
                                                   r['option_values'], r['total_sold'], r['total_seats'], r['remaining_seats']
        )
        trip_instance['option_values'] = (variant.option_values.to_h { |ov| [ov.option_type.attr_type, ov.name] })
        trip_instance
      end
    end

    def trips_info
      result = Spree::Variant.select('spree_variants.id as trip_id,
                              spree_vendors.id as vendor_id,
                              spree_vendors.name as vendor_name,
                              routes.name as route_name,
                              origin.name as origin,
                              destination.name as destination,
                              spree_option_values.name as option_values,
                              COALESCE(ts.total_sold, 0) as total_sold,
                              cm_vehicles.number_of_seats as total_seats,
                              (cm_vehicles.number_of_seats - COALESCE(ts.total_sold, 0))  as remaining_seats
                            '
                                    )
                             .joins('INNER JOIN spree_products routes ON routes.id = spree_variants.product_id')
                             .joins('INNER JOIN spree_option_value_variants ON spree_option_value_variants.variant_id = spree_variants.id')
                             .joins('INNER JOIN spree_option_values ON spree_option_values.id = spree_option_value_variants.option_value_id')
                             .joins('INNER JOIN spree_option_types ON spree_option_types.id = spree_option_values.option_type_id')
                             .joins('INNER JOIN cm_vehicles ON cm_vehicles.id = spree_option_values.name::integer')
                             .joins('INNER JOIN spree_vendors ON spree_vendors.id = spree_variants.vendor_id')
                             .joins('INNER JOIN spree_taxons origin on origin.id = routes.origin_id')
                             .joins('INNER JOIN spree_taxons destination on destination.id = routes.destination_id')
                             .joins("LEFT JOIN (#{total_sold_sql}) ts ON spree_variants.id = ts.trip_id")
                             .where(spree_option_types: { attr_type: 'vehicle' })

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

    # def matching_trips
    #   Spree::Variant.select('spree_variants.id,
    #                         routes.name,
    #                         routes.origin_id,
    #                         routes.destination_id,
    #                         Array_Agg(spree_option_values.name) as option_values,
    #                         spree_variants.vendor_id as vendor_id,
    #                         trs.remaining_seats'
    #                        )
    #                 .joins('INNER JOIN spree_products routes ON routes.id = spree_variants.product_id')
    #                 .joins('INNER JOIN spree_option_value_variants ON spree_option_value_variants.variant_id = spree_variants.id')
    #                 .joins('INNER JOIN  spree_option_values ON spree_option_values.id = spree_option_value_variants.option_value_id')
    #                 .joins("INNER JOIN (#{trip_remaining_seats.to_sql}) AS trs ON spree_variants.id = trs.id")
    #                 .where('routes.origin_id = ? AND routes.destination_id = ?', origin_id, destination_id)
    #                 .group('spree_variants.id, routes.id, trs.remaining_seats')
    # end

    # def trip_remaining_seats
    #   Spree::Variant.select('spree_variants.id,
    #                         (cm_vehicles.number_of_seats - COALESCE(SUM(spree_line_items.quantity), 0)) as remaining_seats
    #                        '
    #                        )
    #                 .joins('INNER JOIN spree_option_value_variants ON spree_option_value_variants.variant_id = spree_variants.id')
    #                 .joins('INNER JOIN  spree_option_values ON spree_option_values.id = spree_option_value_variants.option_value_id')
    #                 .joins('INNER JOIN spree_option_types ON spree_option_types.id = spree_option_values.option_type_id')
    #                 .joins('INNER JOIN cm_vehicles ON cm_vehicles.id::text = spree_option_values.name')
    #                 .joins("LEFT JOIN spree_line_items ON spree_line_items.variant_id = spree_variants.id AND spree_line_items.date = '#{date}'")
    #                 .where(spree_option_types: { attr_type: 'vehicle' })
    #                 .group('spree_variants.id, cm_vehicles.id')
    # end

    def apply_filter(scope)
      scope = scope.where(vendor_id: vendor_id) if vendor_id.present?
      scope
    end
  end
end
