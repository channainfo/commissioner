module Spree
  module Transit
    class AmenitiesController < Spree::Transit::BaseController
      before_action :load_data
      before_action :load_vendor
      before_action :load_amenity
      before_action :setup_new_option_value, only: :edit

      def load_data
        @amenities = Spree::OptionType.all
      end

      def update_values_positions
        ApplicationRecord.transaction do
          params[:positions].each do |id, index|
            Spree::OptionValue.where(id: id).update_all(position: index) # rubocop:disable Rails/SkipsModelValidations
          end
        end

        respond_to do |format|
          format.html { redirect_to spree.transit_routes_url }
          format.js { render plain: 'Ok' }
        end
      end

      def update
        load_amenity
        if @amenity.update(amenity_params)
          flash[:success] = I18n.t('amenity.update_success')
        else
          flash[:error] = "Unable to update Option Type. Errors: #{@amenity.errors.full_messages.join(', ')}"
        end
        redirect_back(fallback_location: edit_transit_amenity_path(@amenity))
      end

      def location_after_save
        edit_transit_amenity_path(@amenity)
      end

      def collection
        load_data

        @objects = model_class.where(kind: :vehicle_type)
        @search = @objects.ransack(params[:q])
        @collection = @search.result

        @collection
      end

      def load_vendor
        @vendor ||= vendors.find { |v| v[:slug] == session[:transit_current_vendor_slug] } || vendors.first
      end

      def model_class
        Spree::OptionType
      end

      def object_name
        'option_type'
      end

      def setup_new_option_value
        @amenity.option_values.build if @amenity.option_values.empty?
      end

      private

      def load_amenity
        ActiveRecord::Base.connected_to(role: :writing) do
          @amenity = Spree::OptionType.amenities
        end
      end

      def amenity_params
        params.require(:option_type).permit(:name, :presentation, :kind, :attr_type, option_values_attributes: {})
      end
    end
  end
end
