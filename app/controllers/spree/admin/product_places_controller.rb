module Spree
  module Admin
    class ProductPlacesController < Spree::Admin::ResourceController
      belongs_to 'spree/product', find_by: :slug

      before_action :load_place_to_product_place, only: [:create]

      create.fails :set_flash_error_message

      def collection
        @collection ||= if params[:type].present?
                          parent.product_places.where(type: params[:type])
                        else
                          parent.product_places
                        end
      end

      # override
      def collection_url
        admin_product_product_places_path(parent)
      end

      # override
      def model_class
        SpreeCmCommissioner::ProductPlace
      end

      # override
      def object_name
        'product_place'
      end

      # override
      def permitted_resource_params
        @permitted_resource_params ||= params[:spree_cm_commissioner_product_place].permit(:place_id, :checkinable_distance, :type, :base_64_content)
      end

      private

      def load_place_to_product_place
        place_base_64_content = permitted_resource_params.delete(:base_64_content)

        if place_base_64_content.blank?
          flash[:error] = I18n.t('product_place.place_required')
          render :new, status: :unprocessable_entity
          return
        end

        place_json = Base64.strict_decode64(place_base_64_content)
        place_hash = JSON.parse(place_json)

        @place = SpreeCmCommissioner::Place.where(reference: place_hash['reference']).first_or_initialize do |place|
          place.assign_attributes(place_hash)
        end

        @place.save! if @place.changed?
        @product_place.place = @place
      end

      def set_flash_error_message
        flash[:error] = @product_place.errors.full_messages.join(', ')
      end
    end
  end
end
