module Spree
  module Billing
    class PlacesController < Spree::Billing::BaseController
      before_action :load_place, if: -> { member_action? }

      def collection
        params[:q] = {} if params[:q].blank?
        places = SpreeCmCommissioner::Place.all

        @search = places.ransack(params[:q])
        @collection = @search.result.page(page).per(per_page)
      end

      def load_place
        @place = @object
      end

      def location_after_save
        billing_places_url
      end

      def model_class
        SpreeCmCommissioner::Place
      end

      def object_name
        'spree_cm_commissioner_place'
      end

      def collection_url(options = {})
        billing_places_url(options)
      end
    end
  end
end
