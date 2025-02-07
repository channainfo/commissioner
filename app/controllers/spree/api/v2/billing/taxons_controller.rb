module Spree
  module Api
    module V2
      module Billing
        class TaxonsController < Spree::Api::V2::BaseController
          def index
            @taxons = Spree::Taxonomy.businesses.taxons.where('depth > ? AND depth < ?', 0, 2).order('parent_id ASC').uniq
            @taxonomies = Spree::Taxonomy.businesses.taxons.where('depth > ?', 1).order('parent_id ASC').uniq

            taxons_with_taxonomies = @taxons.map do |taxon|
              {
                id: taxon.id,
                name: taxon.name,
                parent_id: taxon.parent_id,
                taxonomies: @taxonomies.select { |taxonomy| taxonomy.parent_id == taxon.id }.map do |taxonomy|
                              {
                                id: taxonomy.id,
                                name: taxonomy.name
                              }
                            end
              }
            end

            render json: { taxons: taxons_with_taxonomies }, status: :ok
          end
        end
      end
    end
  end
end
