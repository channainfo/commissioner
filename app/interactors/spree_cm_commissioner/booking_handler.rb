module SpreeCmCommissioner
  class BookingHandler < BaseInteractor
    delegate :variant_id, :params, :service_type, to: :context

    def call
      validate_service_type!

      booking_service(variant_id).book(*booking_param)
    end

    private

    def quanity
      params[:quanity].to_i
    end

    def booking_param
      return [quanity] if service_type == 'event'
      return [Date.parse(params[:trip_date]), quanity] if service_type == 'bus'

      [Date.parse(params[:check_in]), Date.parse(params[:check_out]), quanity]
    end

    def booking_service(variant_id)
      "SpreeCmCommissioner::BookingServices::#{service_type.titleize}Service".constantize.new(variant_id)
    end

    def validate_service_type!
      return context.fail!(message: 'Service type is required') if service_type.blank?

      context.fail!(message: 'Invalid service_type') unless %(event bus accommodation).include? service_type
    end
  end
end
