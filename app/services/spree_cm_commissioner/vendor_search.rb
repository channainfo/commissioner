module SpreeCmCommissioner
  class VendorSearch

    attr_accessor :properties

    def initialize(params)
      @properties = {}
      prepare(params)
    end

    def call
      @vendors = base_elasticsearch
    end

    def base_elasticsearch
      curr_page = page || 1
      Spree::Vendor.search(
        keyword_query,
        fields: Spree::Vendor.search_fields,
        where: where_query,
        page: curr_page,
        per_page: per_page,
      )
    end

    def method_missing(name)
      if @properties.key? name
        @properties[name]
      else
        super
      end
    end


    protected

    def keyword_query
      name.blank? ? "*" : name
    end

    def where_query
      where_query = {
        active: true,
      }
      where_query[:presentation] = province_id.to_s if province_id
      where_query
    end

    def prepare(params)
      @properties[:name] = params[:name]
      @properties[:province_id] = params[:province_id]

      per_page = params[:per_page].to_i
      @properties[:per_page] = per_page > 0 ? per_page : Spree::Config[:products_per_page]
      @properties[:page] = if params[:page].respond_to?(:to_i)
                             params[:page].to_i <= 0 ? 1 : params[:page].to_i
                           else
                             1
                           end
    end
  end
end