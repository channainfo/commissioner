module Spree
  module Transit
    class AmenityController < Spree::Transit::BaseController
      before_action :load_data
      before_action :load_vendor
      before_action :load_amenity, expect: :index
      before_action :setup_new_option_value, expect: :index

      def load_data
        @amenities = Spree::OptionType.all
      end

      def update_values_positions
        ApplicationRecord.transaction do
          params[:positions].each do |id, index|
            Spree::OptionValue.where(id: id).update_all(position: index)
          end
        end

        respond_to do |format|
          format.html { redirect_to spree.transit_routes_url() }
          format.js { render plain: 'Ok' }
        end
      end

      def edit
        if @amenity.persisted?
          render :edit
        else
          render :edit
        end
      end

      def update
        if @amenity.update(amenity_params)
          flash[:success] = "Option Type updated successfully."
          redirect_back(fallback_location: transit_edit_amenity_path(@amenity))
        else
          flash[:error] = "Unable to update Option Type. Errors: " + @amenity.errors.full_messages.join(', ')
          redirect_back(fallback_location: transit_edit_amenity_path(@amenity))
        end
      end

      def load_amenity
        @amenity = Spree::OptionType.where(
                                name: "amenities",
                                presentation: "Amenities",
                                kind: :vehicle_type,
                                attr_type: :amenity).first_or_create
      end

      def amenity_params
        params.require(:option_type).permit(:name, :presentation, :kind, :attr_type, option_values_attributes: {})
      end

      def location_after_save
        transit_edit_amenity_path(@amenity)
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
    end
  end
end