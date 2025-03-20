# rubocop:disable Style/MissingRespondToMissing

module SpreeCmCommissioner
  class AccommodationUnitSearch < BaseInteractor
    delegate :params, to: :context
    before :prepare_params
    before :check_is_detail

    def call
      context.value = context.is_detail ? accommodation_query.first : accommodation_query.page(page).per(per_page)
    end

    def accommodation_query
      SpreeCmCommissioner::AccommodationSearch.new(from_date: from_date, to_date: to_date, province_id: province_id,
                                                  vendor_id: vendor_id, num_guests: num_guests
      ).with_available_inventory
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
        active: true
      }
      where_query[:presentation] = province_id.to_s if province_id
      where_query
    end

    def check_is_detail
      context.properties[:vendor_id] = nil
      context.is_detail = params[:id].present?

      return unless context.is_detail

      resource = Spree::Vendor.find_by(slug: params[:id]) || Spree::Vendor.find_by(id: params[:id])

      context.properties[:vendor_id] = resource.id # accommodation id
    end

    def prepare_params
      context.properties = {}
      per_page = params[:per_page].to_i
      # location
      context.properties[:province_id] = params[:province_id]
      # date_range
      context.properties[:from_date] = params[:from_date].to_date
      context.properties[:to_date] = params[:to_date].to_date
      context.properties[:num_guests] = params[:num_guests].to_i
      # passenger_options
      context.properties[:passenger_options] = passenger_options
      # pagination
      context.properties[:per_page] = per_page.positive? ? per_page : Spree::Config[:products_per_page]
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
# rubocop:enable Style/MissingRespondToMissing
