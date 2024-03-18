module Spree
  module Transit
    class VehicleTypesController < Spree::Transit::BaseController
      before_action :load_amenities, except: %i[index layer]
      before_action :load_status, except: %i[index layer]

      def index
        respond_with(@collection)
      end

      def location_after_save
        edit_transit_vehicle_type_path(@object)
      end

      def layer
        @seats = JSON.parse(params[:seats]).to_a
        @row = params[:row]
        @column = params[:column]
        @layer_name = params[:layer_name]
        @created_at = params[:created_at]
        render :partial => 'spree/transit/vehicle_types/seat_view'
      end

      def load_amenities
        @amenities = Spree::OptionType.amenities.option_values.pluck(:name, :id)
        @selected_option_value_ids = @object.option_values.pluck(:id)
      end

      def load_status
        @statuses = SpreeCmCommissioner::VehicleType.state_machine.states.map(&:name)
      end

      def new
        @vehicle_type = SpreeCmCommissioner::VehicleType.new
      end

      def scope
        @vehicle_types = current_vendor.vehicle_types
      end

      def collection
        return @collection if defined?(@collection)

        scope

        @search = scope.ransack(params[:q])
        @collection = @search.result
      end

      def edit
        @seats = @object.seat_layers
      end

      # overrided
      def permitted_resource_params
        vehicle_type_params = params[:spree_cm_commissioner_vehicle_type]
        selected_option_value_ids = vehicle_type_params[:option_value_ids]

        option_values = Spree::OptionValue.where(id: selected_option_value_ids)
        { option_values: option_values,
          name: vehicle_type_params[:name],
          code: vehicle_type_params[:code],
          vendor_id: vehicle_type_params[:vendor_id],
          route_type: vehicle_type_params[:route_type],
          status: vehicle_type_params[:status],
          allow_seat_selection: vehicle_type_params[:allow_seat_selection],
          vehicle_seats_count: vehicle_type_params[:vehicle_seats_count]
        }
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::VehicleType
      end

      def object_name
        'spree_cm_commissioner_vehicle_type'
      end
    end
  end
end
