module SpreeCmCommissioner
  module InventoryServices
    class InventoryQuery
      def fetch_available_inventory(variant_id, start_date = nil, end_date = nil, service_type)
        inventory_rows = build_scope(variant_id, start_date, end_date, service_type).to_a

        return [] if inventory_rows.empty?
        cached_counts = fetch_cached_counts(inventory_rows)
        build_inventory_results(inventory_rows, cached_counts)
      end

      private

      def build_scope(variant_id, start_date, end_date, service_type)
        scope = InventoryUnit.for_service(service_type)
        scope = scope.where(variant_id: variant_id) if variant_id.present?

        if start_date && end_date
          scope = scope.where(inventory_date: start_date..end_date.prev_day)
        elsif service_type == SpreeCmCommissioner::InventoryUnit::SERVICE_TYPE_EVENT
          scope = scope.where(inventory_date: nil)
        end

        scope
      end

      def fetch_cached_counts(inventory_rows)
        keys = inventory_rows.map { |row| "inventory:#{row.id}" }

        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.mget(*keys)
        end
      end

      def build_inventory_results(inventory_rows, cached_counts)
        inventory_rows.map.with_index do |row, index|
          quantity_available = determine_quantity_available(row, cached_counts[index])
          build_open_struct(row, quantity_available)
        end
      end

      def determine_quantity_available(row, cached_count)
        if cached_count.nil? || row.quantity_available != cached_count.to_i
          cache_inventory(row)
          row.quantity_available
        else
          cached_count.to_i
        end
      end

      def cache_inventory(row)
        key = "inventory:#{row.id}"
        expiration_in = calculate_expiration_in_second(row.inventory_date)

        SpreeCmCommissioner.redis_pool.with do |redis|
          redis.set(key, row.quantity_available, ex: expiration_in)
        end
      end

      def calculate_expiration_in_second(inventory_date)
        # 1 year for events
        return 31_536_000 if inventory_date.blank?

        # Todo: this can return minus result: what is the proper time for storing cache
        # inventory_date.to_time.to_i - Time.now.to_i
        3600 # 1 hour
      end

      def build_open_struct(row, quantity_available)
        OpenStruct.new(
          variant_id: row.variant_id,
          inventory_date: row.inventory_date,
          quantity_available: quantity_available,
          max_capacity: row.max_capacity,
          service_type: row.service_type
        )
      end
    end
  end
end
