module SpreeCmCommissioner
  class TicketsSearcherQuery
    attr_reader :params, :tenant_id

    def initialize(params, tenant_id)
      @params = params
      @tenant_id = tenant_id
    end

    def call
      return Spree::Product.none if tenant_id.blank?

      search = Spree::Product.ransack(
        tenant_id_eq: tenant_id,
        name_i_cont_all: params[:term]&.split
      )

      search.result.distinct
    end
  end
end
