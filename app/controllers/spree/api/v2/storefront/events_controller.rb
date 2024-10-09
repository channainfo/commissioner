module Spree
  module Api
    module V2
      module Storefront
        class EventsController < Spree::Api::V2::ResourceController
          def collection
            organizer_query = SpreeCmCommissioner::OrganizerProfileEventQuery.new(
              vendor_id: vendor.id,
              section: params[:section] || 'upcoming'
            )

            organizer_query.events.page(params[:page]).per(params[:per_page])
          end

          def collection_serializer
            Spree::V2::Storefront::TaxonSerializer
          end

          private

          def vendor
            @vendor ||= Spree::Vendor.find_by(id: params[:vendor_id])
          end
        end
      end
    end
  end
end
