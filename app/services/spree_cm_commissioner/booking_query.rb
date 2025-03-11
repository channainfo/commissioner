require 'redis'

module SpreeCmCommissioner
  class BookingQuery
    def initialize(variant_id:, service_type:)
      @variant_id = variant_id
      @service_type = service_type
      @redis = Redis.new
    end

    def book_inventory(start_date, end_date, quantity)
      inventory_ids = find_inventory_ids(start_date, end_date)
      keys = build_inventory_keys(inventory_ids)

      if update_inventory_counts_in_redis(keys, quantity)
        enqueue_sync_inventory_unit(inventory_ids, quantity)
        true
      else
        raise "Not enough inventory"
      end
    end

    private

    attr_reader :redis, :service_type, :variant_id

    def build_inventory_keys(inventory_ids)
      inventory_ids.map { |id| "inventory:#{id}" }
    end

    def find_inventory_ids(start_date, end_date)
      scope = InventoryUnit.for_service(service_type).where(variant_id: variant_id)
      scope = scope.where(inventory_date: start_date..end_date.prev_day) if start_date && end_date
      scope = scope.where(inventory_date: nil) if service_type == 'event'
      scope.pluck(:id)
    end

    def update_inventory_counts_in_redis(keys, quantity)
      results = decrease_quantity_inventory_in_redis(keys, quantity)
      success = results.all? { |count| count >= 0 }

      rollback_inventory_updates(keys, quantity) unless success
      success
    end

    def decrease_quantity_inventory_in_redis(keys, quantity)
      results = []
      byebug
      RedisConnection.pool.with do|redis|
        redis.pipelined do |pipeline|
          results = keys.map { |key| pipeline.decrby(key, quantity) }
        end
      end

      results.map { |r| r.value }
    end

    def rollback_inventory_updates(keys, quantity)
      RedisConnection.pool.with do|redis|
        redis.pipelined do |pipeline|
          keys.each { |key| pipeline.incrby(key, quantity) }
        end
      end
    end

    def enqueue_sync_inventory_unit(inventory_ids, quantity)
      SyncInventoryJob.perform_later(inventory_ids, quantity)
    end
  end
end
