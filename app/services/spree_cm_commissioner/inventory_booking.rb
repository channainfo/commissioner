module SpreeCmCommissioner
  class InventoryBooking
    def book_inventories(inventory_params = [])
      params = validate_params(inventory_params)
      keys, quantities, inventory_ids = extract_inventory_data(params)

      if reserve_inventory(keys, quantities)
        schedule_sync_inventory(inventory_ids, quantities)
        true
      else
        false
      end
    end

    def can_supply_all?(inventory_params = [])
      params = validate_params(inventory_params)
      keys, quantities = extract_inventory_data(params)
      inventory_available?(keys, quantities)
    end

    private

    # params = [{inventory_key: 'inventory:1', quantity:1}, ...]
    def validate_params(params)
      raise 'Inventory params must be an array' unless params.is_a?(Array)
      raise 'Inventory params cannot be blank' if params.blank?

      params
    end

    def extract_inventory_data(params)
      keys = params.pluck(:inventory_key)
      quantities = params.pluck(:quantity)
      inventory_ids = keys.map { |key| key.split(':').last }

      [keys, quantities, inventory_ids]
    end

    def reserve_inventory(keys, quantities)
      execute_redis_script(booking_script, keys, quantities).positive?
    end

    def inventory_available?(keys, quantities)
      execute_redis_script(can_supply_script, keys, quantities).positive?
    end

    def execute_redis_script(script, keys, quantities)
      SpreeCmCommissioner.redis_pool.with do |redis|
        redis.eval(script, keys: keys, argv: quantities)
      end
    end

    def can_supply_script
      <<~LUA
        local keys = KEYS
        local quantities = ARGV

        -- Check availability
        for i, key in ipairs(keys) do
          local current = tonumber(redis.call('GET', key) or 0)
          if current - tonumber(quantities[i]) < 0 then
            return 0
          end
        end

        return 1
      LUA
    end

    def booking_script
      <<~LUA
        local keys = KEYS
        local quantities = ARGV

        -- Check availability first
        for i, key in ipairs(keys) do
          local current = tonumber(redis.call('GET', key) or 0)
          if current - tonumber(quantities[i]) < 0 then
            return 0
          end
        end

        -- Apply updates
        for i, key in ipairs(keys) do
          redis.call('DECRBY', key, tonumber(quantities[i]))
        end

        return 1
      LUA
    end

    def schedule_sync_inventory(inventory_ids, quantities)
      SpreeCmCommissioner::InventoryItemSyncerJob.perform_later(inventory_ids, quantities)
    end
  end
end
