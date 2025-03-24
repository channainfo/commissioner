module SpreeCmCommissioner
  class InventoryFetcher < BaseInteractor
    delegate :variants, :params, :service_type, to: :context

    def call
      validate_service_type!

      context.results = variants.map { |variant| fetch_inventory(variant.id) }
    end

    private

    def fetch_inventory(variant_id)
      inventory_service(variant_id).fetch_inventory(*fetching_param)
    end

    def fetching_param
      return [] if service_type == 'event'
      return [Date.parse(params[:trip_date])] if service_type == 'bus'
      [Date.parse(params[:check_in]), Date.parse(params[:check_out]), params[:num_guests].to_i]
    end

    def inventory_service(variant_id)
      "SpreeCmCommissioner::InventoryServices::#{service_type.titleize}Service".constantize.new(variant_id)
    end

    def validate_service_type!
      return context.fail!(message: 'Service type is required') if service_type.blank?

      context.fail!(message: 'Invalid service_type') unless %(event bus accommodation).include? service_type
    end
  end
end
