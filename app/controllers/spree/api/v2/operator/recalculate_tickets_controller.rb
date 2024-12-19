module Spree
  module Api
    module V2
      module Operator
        class RecalculateTicketsController < ::Spree::Api::V2::ResourceController
          before_action :require_spree_current_user, only: :create
          before_action :load_taxon, only: :create

          def create
            classification_ids = Spree::Classification.joins(:taxon)
                                                      .where(spree_taxons: { id: @taxons.pluck(:id) })
                                                      .pluck(:id)

            classification_ids.each do |classification_id|
              SpreeCmCommissioner::ConversionPreCalculator.call(product_taxon: Spree::Classification.find(classification_id))
            end

            render json: { message: 'Conversions recalculated successfully' }, status: :ok
          end

          private

          def load_taxon
            parent_taxon = Spree::Taxon.find(params[:taxon_id])
            @taxons = parent_taxon.children
          end
        end
      end
    end
  end
end
