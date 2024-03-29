module Spree
  module Api
    module V2
      module Storefront
        class HomepageBackgroundController < ::Spree::Api::V2::ResourceController
          def model_class
            SpreeCmCommissioner::HomepageBackground
          end

          def resource_serializer
            SpreeCmCommissioner::V2::Storefront::HomepageBackgroundSerializer
          end

          def resource
            @resource ||= model_class.active.where(segment: params[:homepage_id] || :general).order(priority: :asc).first
          end
        end
      end
    end
  end
end
