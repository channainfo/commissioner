module SpreeCmCommissioner
  class InventoryServices::BaseService
    def initialize(variant_id)
      @variant_id = variant_id
      @inventory_query = InventoryQuery.new
    end

    def fetch_available_inventory(start_date = nil, end_date = nil)
      @inventory_query.fetch_available_inventory(@variant_id, start_date, end_date, service_type)
    end

    private

    def service_type
      raise "Need to define from sub class"
    end
  end
end
