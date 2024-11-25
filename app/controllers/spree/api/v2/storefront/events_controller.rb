module Spree
  module Api
    module V2
      module Storefront
        class EventsController < Spree::Api::V2::ResourceController
          def collection
            events_query.events
                        .includes(:vendor)
                        .page(params.fetch(:page, 1))
                        .per(params.fetch(:per_page, 20))
          end

          def collection_serializer
            Spree::V2::Storefront::TaxonSerializer
          end

          private

          def events_query
            SpreeCmCommissioner::OrganizerProfileEventQuery.new(
              vendor_id: params[:vendor_id],
              section: params.fetch(:section, 'upcoming'),
              start_from_date: params[:start_from_date] || nil
            )
          end
        end
      end
    end
  end
end
