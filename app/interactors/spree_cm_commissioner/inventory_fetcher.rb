module SpreeCmCommissioner
  class InventoryFetcher < BaseInteractor
    delegate :variant_ids, :params, :product_type, to: :context

    def call
      validate_params!

      context.results = fetch_inventories
    end

    private

    def fetch_inventories
      inventory_service.fetch_inventory
    end

    def inventory_service
      case product_type
      when SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION
        SpreeCmCommissioner::AccommodationInventory.new(
          variant_ids: variant_ids,
          check_in: Date.parse(params[:check_in]),
          check_out: Date.parse(params[:check_out]),
          num_guests: params[:num_guests].to_i
        )
      when SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS
        SpreeCmCommissioner::BusInventory.new(variant_ids: variant_ids, trip_date: Date.parse(params[:trip_date]))
      when SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_EVENT
        SpreeCmCommissioner::EventInventory.new(variant_ids: variant_ids)
      end
    end

    def validate_params!
      return context.fail!(message: 'Variant IDs are required') if variant_ids.blank?
      return context.fail!(message: 'Product type is required') if product_type.blank?

      context.fail!(message: "Missing required parameters for product type '#{product_type}'") if invalid_fetching_params?
    end

    def invalid_fetching_params?
      case product_type
      when SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION
        params[:check_in].blank? || params[:check_out].blank? || params[:num_guests].blank?
      when SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_BUS
        params[:trip_date].blank?
      when SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_EVENT
        false # No specific params required for events
      else
        true # Unknown product type
      end
    end
  end
end
