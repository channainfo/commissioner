module SpreeCmCommissioner
  class VendorSearch < BaseInteractor
    delegate :params, to: :context

    def call
      prepare_params
      context.vendors = vendor_query.vendor_with_available_inventory.page(page).per(per_page)
    end

    def vendor_query
      SpreeCmCommissioner::VendorQuery.new(from_date: from_date, to_date: to_date, province_id: province_id)
    end

    def method_missing(name)
      if context.properties.key? name
        context.properties[name]
      else
        super
      end
    end

    protected

    def where_query
      where_query = {
        active: true,
      }
      where_query[:presentation] = province_id.to_s if province_id
      where_query
    end

    def prepare_params
      context.properties = {}
      per_page = params[:per_page].to_i
      # name and location
      context.properties[:province_id] = params[:province_id].to_i
      # date_range
      context.properties[:from_date] = params[:from_date].to_date
      context.properties[:to_date] = params[:to_date].to_date
      # passenger_options
      context.properties[:passenger_options] = passenger_options
      # pagination
      context.properties[:per_page] = per_page > 0 ? per_page : Spree::Config[:products_per_page]
      context.properties[:page] = if params[:page].respond_to?(:to_i)
                             params[:page].to_i <= 0 ? 1 : params[:page].to_i
                           else
                             1
                           end
    end

    def passenger_options
      SpreeCmCommissioner::PassengerOption.new(adult: params[:adult], children: params[:children], room_qty: params[:room_qty])
    end
  end
end