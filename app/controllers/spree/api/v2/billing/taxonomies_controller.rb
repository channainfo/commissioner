module Spree
  module Api
    module V2
      module Billing
        class TaxonomiesController < Spree::Api::V2::BaseController
          def index
            @taxonomies = Spree::Taxonomy.businesses.taxons.where('depth > ? ', 1).where(parent_id: params[:taxon_id]).order('parent_id ASC').uniq
            render json: @taxonomies, each_serializer: Spree::V2::Billing::TaxonomySerializer
          end
        end
      end
    end
  end
end
