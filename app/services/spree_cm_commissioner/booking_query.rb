module SpreeCmCommissioner
  class BookingQuery
    def initialize(variant_id:, service_type:)
      @variant_id = variant_id
      @service_type = service_type
    end

    def book_inventory!(start_date, end_date, quantity)
      inventory_ids = fetch_available_inventory(start_date, end_date)
      inventory_keys = generate_inventory_keys(inventory_ids)

      if reserve_inventory(inventory_keys, quantity)
        schedule_sync_inventory(inventory_ids, quantity)
        true
      else
        raise StandardError, "Not enough inventory available"
      end
    end

    private

    attr_reader :variant_id, :service_type

    def fetch_available_inventory(start_date, end_date)
      scope = InventoryUnit.for_service(service_type).where(variant_id: variant_id)
      scope = scope.where(inventory_date: start_date..end_date.prev_day) if start_date && end_date
      scope = scope.where(inventory_date: nil) if service_type == InventoryUnit::SERVICE_TYPE_EVENT
      scope.pluck(:id)
    end

    def generate_inventory_keys(inventory_ids)
      inventory_ids.map { |id| "inventory:#{id}" }
    end

    def reserve_inventory(keys, quantity)
      SpreeCmCommissioner.redis_pool.with do |redis|
        redis_transaction_result(redis, keys, quantity).positive?
      end
    end

    def redis_transaction_result(redis, keys, quantity)
      redis.eval(
        inventory_update_script,
        keys: keys,
        argv: [quantity]
      )
    end

    def inventory_update_script
      <<~LUA
        local keys = KEYS
        local qty = tonumber(ARGV[1])
        local original_counts = {}
        local new_counts = {}

        -- Capture original counts and attempt decrement
        for i, key in ipairs(keys) do
          original_counts[i] = redis.call('GET', key) or 0
          new_counts[i] = redis.call('DECRBY', key, qty)
        end

        -- Validate all new counts are non-negative
        for i, count in ipairs(new_counts) do
          if tonumber(count) < 0 then
            -- Rollback transaction if any count goes negative
            for j, key in ipairs(keys) do
              redis.call('SET', key, original_counts[j])
            end
            return 0
          end
        end

        return 1
      LUA
    end

    def schedule_sync_inventory(inventory_ids, quantity)
      SyncInventoryJob.perform_later(inventory_ids, quantity)
    end
  end
end
