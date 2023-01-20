module SpreeCmCommissioner
  class VendorDetail < BaseInteractor
    delegate :params, to: :context
    before :prepare_params

    def call
      context.vendor = vendor_query.vendor_with_available_inventory.first
    end

    def vendor_query
      SpreeCmCommissioner::VendorQuery.new(from_date: from_date, to_date: to_date, vendor_id: vendor_id)
    end

    protected
    attr_reader :vendor_id, :from_date, :to_date

    def prepare_params
      @vendor_id = params[:vendor_id].to_i
      @from_date = params[:from_date].to_date
      @to_date = params[:to_date].to_date
    end
  end
end