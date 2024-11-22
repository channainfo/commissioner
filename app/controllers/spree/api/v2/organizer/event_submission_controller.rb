module Spree
  module Api
    module V2
      module Organizer
        class EventSubmissionController < ApplicationController
          def collection
            @taxon = Taxon.all
          end

          private

          def collection_serializer
            SpreeCmCommissioner::V2::Organizer::EventSubmissionSerializer
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Organizer::EventSubmissionSerializer
          end

          def submission_params
            params.require(:taxon).permit(:name, :phone_number, :email, :image, :description)
          end
        end
      end
    end
  end
end
