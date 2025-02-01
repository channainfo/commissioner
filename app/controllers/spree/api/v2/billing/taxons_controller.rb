module Spree
  module Api
    module V2
      module Billing
        class TaxonsController < Spree::Api::V2::BaseController
          def index
            @taxons = Spree::Taxonomy.businesses.taxons.where('depth > ? AND depth < ?', 0, 2).order('parent_id ASC').uniq
            render json: @taxons, each_serializer: Spree::V2::Billing::TaxonSerializer
          end
        end
      end
    end
  end
end
