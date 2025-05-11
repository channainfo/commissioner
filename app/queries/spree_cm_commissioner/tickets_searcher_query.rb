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
        name_i_cont_all: sanitized_terms
      )

      search.result.distinct
    end

    private

    def sanitized_terms
      return [] if params[:term].blank?

      params[:term].split.map(&:strip)
    end
  end
end
