module SpreeCmCommissioner
  class AccommodationDetail < BaseInteractor
    delegate :params, to: :context
    before :validate_resource_by_slug
    before :prepare_params

    def call
      context.value = accommodation_query.with_available_inventory.first
    end

    def accommodation_query
      SpreeCmCommissioner::AccommodationQuery.new(from_date: from_date, to_date: to_date, id: id)
    end

    protected
    attr_reader :id, :from_date, :to_date, :resource

    def validate_resource_by_slug
      @resource = Spree::Vendor.find_by(slug: params[:id])

      context.fail!(error: "The accommodation you were looking for could not be found.") if @resource.nil?
    end

    def prepare_params
      @id = @resource.id
      @from_date = params[:from_date].to_date
      @to_date = params[:to_date].to_date
    end
  end
end